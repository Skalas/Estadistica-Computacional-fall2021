# Librerías -----------------------------------------------------------------------------------
# LibrerÌas requeridas
required <- c('readxl','dplyr','tidyr','sp','shiny','leaflet','DT', 'leaflet.extras',
              'data.table', 'htmltools', 'htmlwidgets', 'shinyjs', 'shinythemes','rstudioapi')

# Instalar librerías en caso de que no existan en local
if (sum(!(required %in% installed.packages())) > 0){
    lapply(list(required[!(required %in% installed.packages())]), install.packages)
}

# Cargar librerías
lapply(required, library, character.only=TRUE)

# Limpieza de refugios ------------------------------------------------------------------------
# Cargar archivo
path <- '../../Skalas/data/refugios_nayarit.xlsx'
df <- lapply(excel_sheets(path), read_xlsx, path=path, col_names=FALSE, skip=6) %>% bind_rows()

# Renombrar columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios',
              'capacidad','lat','lng','alt','responsable','tel')

# Parsear `lat` y `lng`
df <- df %>%
    # Sin NAs
    drop_na(c(lat,lng)) %>% 
    # Quitar espacios
    mutate(lat=gsub(' ','',lat), lng=gsub(' ','',lng)) %>%
    # Casos especiales
    mutate(lat=gsub('º\'|°\'','º',lat)) %>%
    # Split sobre números
    separate(lat, into=paste0('lat', 1:4), sep='[^0-9]', remove=FALSE) %>% 
    separate(lng, into=paste0('lng', 1:4), sep='[^0-9]', remove=FALSE) %>% 
    # Quitar registros que les falta al menos un elemento o exceden Nayarit
    filter(
        !(is.na(lat4) | is.na(lng4))
        & between(lat1,20,24)
        & between(lng1,103,106)
    ) %>% 
    # Formato correcto DMS
    mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'.',lat4,'sN')) %>%
    mutate(lng=paste0(lng1,'d',lng2,'m',lng3,'.',lng4,'sW')) %>%
    # Ordenar columnas
    select(c('refugio','direccion','municipio','tipo','servicios',
             'capacidad','responsable','tel','lng','lat','alt'))

# Convertir coordenadas de STR a DMS a NUM y quitar casos que no se parsean con patrón
df <- df %>%
    mutate(lat=char2dms(from=lat, chd='d', chm='m', chs='s') %>% as.numeric()) %>% 
    mutate(lng=char2dms(from=lng, chd='d', chm='m', chs='s') %>% as.numeric())

# Convertir datos planos a SpatialPointDataFrame
proj <- CRS("+proj=longlat +datum=WGS84")
df <- SpatialPointsDataFrame(coords=df %>% select(c(lng, lat)), data=df, proj4string=proj)

# User Interface ------------------------------------------------------------------------------
ui <- fluidPage(
    theme = shinytheme("yeti"),
    tabsetPanel(
        id = "wizard",
        type = "hidden",
        tabPanel("page_1",
                 img(src = "logo.png", height = 100, width = 200),
                 br(),
                 h1("Bienvenido:", span("encuentra tu refugio más cercano", style = "font-weight: 'Source Sans Pro'"), 
                    style = "font-family: 'Source Sans Pro';color: black; text-align: center"),
                 
                 br(),
                 
                 fluidRow(
                     column(10, offset = 1,
                            p(strong("Por favor elige la opción que más te convenga:"),
                              style = "font-family: 'Source Sans Pro';text-aling: justify"),
                            p("-", strong("Ubicación actual:"), "si no conoces tus coordenadas,
                            esta opción te permite calcular el refugio más cercano a partir de tu
                            ubicación actual. Debes permitir al navegador obtener tu ubicación.",
                              style = "font-family: 'Source Sans Pro'; text-align: justify"),
                            p("-", strong("Ingresar coordenadas:"), "si quieres encontrar el refugio más cercano a partir
                       de las coordenadas de tu preferencia, entonces elige esta opción.",
                              style = "font-family: 'Source Sans Pro';text-align: justify"),
                     )
                 ),
                 
                 column(1, offset = 2,
                        actionButton("next_12", "Ubicación actual")),
                 column(1, offset = 5,
                        actionButton("next_13", "Ingresar coordenadas"))
        ),
        tabPanel("page_2",
                 actionButton("back_21", "Inicio"),
                 sidebarLayout(
                     sidebarPanel(
                         sliderInput(
                             'nref_mu',
                             'Elige cuántos refugios cercanos quieres ver y oprime calcular',
                             min=1, max=10, value=3
                         ),
                     ),
                     mainPanel(
                         tabsetPanel(
                             tabPanel(
                                 'Mapa',
                                 actionButton("calcular", "Calcular"),
                                 leafletOutput('mymap2', height=800)
                                 
                                 
                                 
                             ), 
                             tabPanel(
                                 'Detalle',
                                 DTOutput('table2')
                             )
                         )
                     )
                 )
        ),
        tabPanel("page_3",
                 actionButton("back_31", "Inicio"),
                 sidebarLayout(
                     sidebarPanel(
                         numericInput('lng', 'Ingresa tu longitud', value=-105, min=-180, max=180),
                         numericInput('lat', 'Ingresa tu latitud', value=22, min=-90, max=90),
                         sliderInput(
                             'nref',
                             '¿Cuántos refugios cercanos quieres ver?',
                             min=1, max=10, value=3
                         ),
                     ),
                     mainPanel(
                         tabsetPanel(
                             tabPanel(
                                 'Mapa',
                                 leafletOutput('mymap', height=800)
                                 
                             ),
                             tabPanel(
                                 'Detalle',
                                 DTOutput('table')
                             )
                         )
                     )
                 )
        )
    )
)

#Mapa con el que autocalculamos la ubicación.
basemap1 <-  leaflet(options = leafletOptions(minZoom = 5))%>%
    addProviderTiles(
        "OpenStreetMap",
        group = "OpenStreetMap"
    ) %>% 
    addControlGPS(options = gpsOptions(position = "topleft", activate = TRUE, 
                                       autoCenter = TRUE, 
                                       setView = TRUE)) %>% activateGPS()



server <- function(input, output, session) {
    
    #Función para cambiar entre paneles
    switch_page <- function(i) {
        updateTabsetPanel(inputId = "wizard", selected = paste0("page_", i))
    }
    
    #Uso de botones para cambio de paneles
    observeEvent(input$next_12, switch_page(2))
    observeEvent(input$back_21, switch_page(1))
    observeEvent(input$next_13, switch_page(3))
    observeEvent(input$back_31, switch_page(1))
    
    # Codigo en el que proporcionas coordenadas 
    
    #Calculamos los puntos de referencia con las coordenadas dadas
    user_loc <- reactive(
        SpatialPoints(
            coords=matrix(data=c(input$lng, input$lat), nrow=1),
            proj=CRS("+proj=longlat +datum=WGS84")
        )
    )
    # Calcular distancia de user_loc -> todos los refugios
    sort_df <- reactive(
        df@data %>% 
            # Columna de distancias
            mutate(dist=spDists(user_loc(), df)[1,]) %>% 
            # Ordenar por distancia
            arrange(dist) %>% 
            # TopN refugios
            head(input$nref) %>% 
            # Rank por cercanía
            mutate(cercania=1:input$nref) %>% 
            select(c(cercania,refugio,direccion,municipio,
                     capacidad,servicios,lng,lat))
    )
    
    #Obtenemos el mapa a partir de las ditancias caluladas
    output$mymap <- renderLeaflet({
        leaflet() %>% 
            addTiles() %>% 
            setView(zoom=9, lng=input$lng, lat=input$lat) %>% 
            addMarkers(
                data=sort_df(),
                lng=~lng,
                lat=~lat,
                label = ~refugio ,
                popup=~paste0(
                    #'Nombre de refugio: ', refugio, '<br>',
                    "<b>", 'Dirección: ', "</b>", direccion, "<br>",
                    "<b>", ' Municipio ', "</b>", municipio, '<br>',
                    "<b>", 'Cercanía de refugio: ',"</b>", cercania, ' de ', input$nref, '<br>',
                    "<b>", 'Servicios disponibles: ', "</b>", servicios
                )
            ) %>% 
            addCircleMarkers(
                lng=input$lng,
                lat=input$lat,
                radius = 3,
                color = 'red',
                label='Tú estás aquí',
                clusterOptions = markerClusterOptions()
            )
    })
    
    #Generamos la salida de la tabla resumen con el top 10 de los refugios más cercanos
    output$table <- renderDT({
        sort_df()
    })
    
    
    #Codigo en el que elegimos 'Ubicación actual'   
    
    #Mapa en el que autocalculamos la ubicación con activeGPS()
    output$mymap2 <- renderLeaflet(basemap1)
    
    #Imprime las coordenadas de acuerdo a la ubicación
    observeEvent(input$next_12, {
        observe(
            print(input$mymap2_gps_located))
    })
    
    #Calculamos los puntos de referencia con la ubicación actual
    user_loc_mu <- reactive(
        SpatialPoints(
            coords=matrix(data=c(as.numeric(input$mymap2_gps_located[[1]][2]), 
                                 as.numeric(input$mymap2_gps_located[[1]][1])), nrow=1),
            proj=CRS("+proj=longlat +datum=WGS84")
        )
    )
    
    # Calcular distancia de user_loc_mu -> todos los refugios
    sort_df_mu <- reactive(
        df@data %>% 
            # Columna de distancias
            mutate(dist=spDists(user_loc_mu(), df)[1,]) %>% 
            # Ordenar por distancia
            arrange(dist) %>% 
            # TopN refugios
            head(input$nref_mu) %>% 
            # Rank por cercan√≠a
            mutate(cercania=1:input$nref_mu) %>% 
            select(c(cercania,refugio,direccion,municipio,
                     capacidad,servicios,lng,lat))
    )
    
    #Sobre el mapa 'renderizado' calculamos ubicamos los puntos más cercanos a nuesta ubicación
    observeEvent(input$calcular,
                 #Aquí se modifica el mapa que ya hemos renderisado
                 leafletProxy("mymap2", session) %>% 
                     clearMarkers() %>%
                     addMarkers(
                         data=sort_df_mu(),
                         lng=~lng,
                         lat=~lat,
                         label = ~refugio, 
                         popup=~paste0(
                             #'Nombre de refugio: ', refugio, '<br>',
                             "<b>", 'Dirección: ', "</b>", direccion, "<br>",
                             "<b>", ' Municipio ', "</b>", municipio, '<br>',
                             "<b>", 'Cercanía de refugio: ',"</b>", cercania, ' de ', input$nref, '<br>',
                             "<b>", 'Servicios disponibles: ', "</b>",servicios
                         ))
    )
    
    #Generamos la salida de la tabla resumen con el top 10 de los refugios más cercanos
    output$table2 <- renderDT({
        sort_df_mu()
        
        
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

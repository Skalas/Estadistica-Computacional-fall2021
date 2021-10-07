# Librerías -----------------------------------------------------------------------------------

# Librerías requeridas
required <- c('readxl','dplyr','tidyr','sp','shiny','leaflet','DT')

# Instalar librerías en caso de que no existan en local
if (sum(!(required %in% installed.packages())) > 0){
    lapply(list(required[!(required %in% installed.packages())]), install.packages)
}

# Cargar librerías
lapply(required, library, character.only=TRUE)


# Limpieza de refugios ------------------------------------------------------------------------

# Cargar archivo
path <- '../dat/refugios_nayarit.xlsx'
df <- lapply(excel_sheets(path), read_xlsx, path=path, col_names=FALSE, skip=6) %>% bind_rows()

# Renombrar columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios','capacidad','lat',
              'lng','alt','responsable','tel')

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
        & between(lat1,21,22)
        & between(lng1,104,105)
    ) %>% 
    # Formato correcto DMS
    mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'.',lat4,'sN')) %>%
    mutate(lng=paste0(lng1,'d',lng2,'m',lng3,'.',lng4,'sW')) %>%
    # Ordenar columnas
    select(c(refugio,direccion,municipio,tipo,servicios,
             capacidad,responsable,tel,lng,lat,alt))

# Convertir coordenadas de STR a DMS a NUM y quitar casos que no se parsean con patrón
df <- df %>%
    mutate(lat=char2dms(from=lat, chd='d', chm='m', chs='s') %>% as.numeric()) %>% 
    mutate(lng=char2dms(from=lng, chd='d', chm='m', chs='s') %>% as.numeric())

# Convertir datos planos a SpatialPointDataFrame
proj <- CRS("+proj=longlat +datum=WGS84")
df <- SpatialPointsDataFrame(coords=df %>% select(c(lng, lat)), data=df, proj4string=proj)


# UI ------------------------------------------------------------------------------------------

ui <- fluidPage(
    titlePanel('Encuentra tu refugio más cercano'),
    sidebarLayout(
        sidebarPanel(
            numericInput('lng', 'Ingresa tu longitud', value=-104.6, min=-180, max=180),
            numericInput('lat', 'Ingresa tu latitud', value=21.2, min=-90, max=90),
            sliderInput(
                'nref',
                '¿Cuántos refugios cercanos quieres ver en la tabla?',
                min=1, max=10, value=3
            )
        ),
        mainPanel(
            tabsetPanel(
                tabPanel(
                    'Mapa',
                    leafletOutput('mapa')
                ),
                tabPanel(
                    'Tabla',
                    DTOutput('table')
                )
            )
        )
    )
)


# Server --------------------------------------------------------------------------------------

server <- function(input, output) {
    # Convertir lng-lat del usuario a SP
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
            select(c('cercania','refugio','direccion','municipio',
                     'capacidad','servicios','lat','lng'))
    )
    # Mapa con Top1 refugio más cercano
    output$map <- renderLeaflet(
        leaflet(sort_df()) %>%
            addTiles() %>% 
            addCircleMarkers(lng=~lng, lat=~lat)
    )
    # Tabla de TopN refugios cercanos
    output$table <- renderDT({
        sort_df()
    })
}

shinyApp(ui = ui, server = server)
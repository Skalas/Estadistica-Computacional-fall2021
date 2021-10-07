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
temp <- df

# Renombrar columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios','capacidad','lat',
              'long','alt','responsable','tel')

# Parsear `lat` y `long`
df <- df %>%
    filter(!(is.na(id) | is.na(lat) | is.na(long))) %>%         # Sin NAs en [id,lat,long]
    mutate(lat=gsub(' ','',lat), long=gsub(' ','',long)) %>%    # Quitar espacios
    mutate(lat=gsub('º\'|°\'','º',lat)) %>%                     # Quitar casos raros
    separate(lat, into=paste0('lat', 1:4), sep='[^0-9]') %>% 
    separate(long, into=paste0('long', 1:4), sep='[^0-9]') %>% 
    mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'.',lat4,'s')) %>% 
    mutate(long=paste0(long1,'d',long2,'m',long3,'.',long4,'s')) %>% 
    select(-c(lat1,lat2,lat3,lat4,long1,long2,long3,long4)) # Quitar columnas temporales

# Convertir coordenadas de STR a DMS a NUM y quitar casos que no se parsean con patrón
df <- df %>%
    mutate(lat=char2dms(from=df$lat, chd='d', chm='m', chs='s') %>% as.numeric()) %>% 
    mutate(long=char2dms(from=df$long, chd='d', chm='m', chs='s') %>% as.numeric()) %>% 
    filter(!(is.na(responsable) | is.na(tel)))

# Convertir datos planos a SpatialPointDataFrame
proj <- CRS("+proj=longlat +datum=WGS84")
df <- SpatialPointsDataFrame(coords=df %>% select(c(long, lat)), data=df, proj4string=proj)


# UI ------------------------------------------------------------------------------------------

ui <- fluidPage(
    titlePanel('Refugio más cercano'),
    sidebarLayout(
        sidebarPanel(
            numericInput('lon', 'Longitud', value=105, min=-180, max=180),
            numericInput('lat', 'Latitud', value=21.5, min=-90, max=90),
            sliderInput(
                'nref',
                '¿Cuántos refugios cercanos quieres ver en la tabla?',
                min=1, max=10, value=3
            )
        ),
        mainPanel(
            tabsetPanel(
                tabPanel(
                    'Mapa'
                ),
                tabPanel(
                    'Tabla',
                    DTOutput('table')
                )
            )
        )
    )
)


server <- function(input, output) {
    # Convertir lon-lat del usuario a SP
    user_loc <- reactive(
        SpatialPoints(
            coords=matrix(data=c(input$lon, input$lat), nrow=1),
            proj=CRS("+proj=longlat +datum=WGS84"))
    )
        # Calcular distancia desde user_loc -> todos los refugios
    sort_df <- reactive(
        df@data %>% 
            mutate(dist=spDists(x=user_loc(), y=df)[1,]) %>% 
            arrange() %>% 
            head(input$nref) %>% 
            select(c('refugio','direccion','municipio','capacidad','servicios','long','lat'))
    )
    
    output$table <- renderDT({
        sort_df()
    })
}

shinyApp(ui = ui, server = server)
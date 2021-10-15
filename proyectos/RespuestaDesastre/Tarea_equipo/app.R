#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, tidyverse, measurements, tidyr, stringr, shiny, shinyWidgets, DT, leaflet, htmlwidgets, shinydashboard, geosphere)


# Nombres de cada una de las hojas del excel 
hojas <- excel_sheets('data/refugios_nayarit.xlsx')

# Lista con cada uno de los refugios 
lista_refugios <- lapply(hojas, function(x)
    read_excel('data/refugios_nayarit.xlsx', sheet = x, skip = 5))

# Dataframe a utilizar
refugios <- do.call('rbind' ,lista_refugios)
colnames(refugios) <- c('No', 'Refugio', 'Municipio', 'Direccion', 'Uso del Inmueble', 'Servicios', 'Capacidad de personas', 'Latitud', 'Longitud', 'Altitud', 'Responsable', 'Telefono')

# Se eliminan las filas con NAN en la columna Refugio
refugios <- refugios %>% drop_na(Refugio)

# Se eliminan los refugios que no tenemos ubicación
refugios_ubicacion <- refugios %>% drop_na(Latitud)

# Se limpian las cordenadas de los caracteres que no necesitamos
lat <- refugios_ubicacion$Latitud 
lat <- gsub("°|'", ' ', lat)
lat <- gsub("º|ª", ' ', lat)
lat <- gsub('"|  ', ' ', lat)
lat <- gsub('-', '.', lat)
lat<- gsub('\\|', ' ', lat)
lat<- gsub('`', ' ', lat)

# Se dejan las coordenadas limpias
refugios_ubicacion$Latitud <- lat

# Se parten las coordenadas en 4 para poder dejar en el formato adecuado
cd<- refugios_ubicacion %>% 
    separate(Latitud, c('l1', 'l2', 'l3', 'l4'),)

# Se regresan las coordenadas en el formato adecuado
refugios_ubicacion$Latitud <- str_c(cd$l1, ' ', cd$l2, ' ', cd$l3, '.', cd$l4)

# Se limpian las cordenadas de los caracteres que no necesitamos
lon <- refugios_ubicacion$Longitud 
lon <- gsub("°|'", ' ', lon)
lon <- gsub("º|ª", ' ', lon)
lon<- gsub('"|  ', ' ', lon)
lon <- gsub('-', '.', lon)
lon<- gsub('\\|', ' ', lon)
lon<- gsub('`', ' ', lon)

# Se dejan las coordenadas limpias
refugios_ubicacion$Longitud <- lon

# Se parten las coordenadas en 4 para poder dejar en el formato adecuado
c<- refugios_ubicacion %>% 
    separate(Longitud, c('l1', 'l2', 'l3', 'l4'),)

# Se regresan las coordenadas en el formato adecuado
refugios_ubicacion$Longitud <- str_c(c$l1, ' ', c$l2, ' ', c$l3, '.', c$l4)

# Se eliminan las coordenadas que se convirtieron en NA por tener datos faltantes
refugios_ubicacion <- refugios_ubicacion %>% drop_na(Latitud)
refugios_ubicacion <- refugios_ubicacion %>% drop_na(Longitud)

# Se eliminan las coordenadas que son incorrectas por tener un dato faltante
row=1
for (i in refugios_ubicacion$Longitud){
    if (str_length(i)<10){
        refugios_ubicacion <- refugios_ubicacion[-c(row), ]
    }
    row=row+1
}

row = 1
for (i in refugios_ubicacion$Latitud){
    if (str_length(i)<10){
        refugios_ubicacion <- refugios_ubicacion[-c(row), ]
    }
    row=row+1
}

# Se realiza la conversión de las coordenadas para poder manipularlas facilmente
refugios_ubicacion$Latitud <- conv_unit(refugios_ubicacion$Latitud, 'deg_min_sec', 'dec_deg')
refugios_ubicacion$Longitud <- conv_unit(refugios_ubicacion$Longitud, 'deg_min_sec', 'dec_deg')

a <- length(refugios_ubicacion$No)
# For para cambiar las coordenadas que esten en la columna adecuada
for (i in 1:a){
    if (as.numeric(refugios_ubicacion$Longitud[i]) < as.numeric(refugios_ubicacion$Latitud[i])){
        real_lat = refugios_ubicacion$Longitud[i]
        real_long = refugios_ubicacion$Latitud[i]
        refugios_ubicacion$Latitud[i] = real_lat
        refugios_ubicacion$Longitud[i] = real_long
    }
}

# Se cambia los valores a numerico de las coordenadas
refugios_ubicacion$Longitud <- -as.numeric(refugios_ubicacion$Longitud)
refugios_ubicacion$Latitud <- as.numeric(refugios_ubicacion$Latitud)

# Columna para utilizar como texto popup para marcadores
refugios_ubicacion <- refugios_ubicacion %>% 
    mutate(popup_text =paste("<h3 style ='color: blue'>", refugios_ubicacion$No, refugios_ubicacion$Refugio, '</h3>',
                             '<b>Dirección:</b>', refugios_ubicacion$Direccion, '<br>',
                             '<b>Capacidad:</b>', refugios_ubicacion$`Capacidad de personas`, '<br>', 
                             '<b>Contacto:</b>', refugios_ubicacion$Responsable, refugios_ubicacion$Telefono))
                         
# UI 
ui <- fluidPage(
# 
   navbarPage('Refugios Nayarit', id='nav',
              # Tab para la exploración de los datos
              tabPanel('Información de refugios',
                       fluidRow( column(3,
                                        selectInput('municipios', 'Municipio',
                                                    c('Todos los municipios'='', structure(refugios_ubicacion$Municipio)), multiple = TRUE)),
                                        column(3, 
                                               conditionalPanel('input.municipios',
                                                                selectInput('direccion', 'Dirección', c('Direcciones'=''), multiple = TRUE))),
                                        column(3, 
                                               conditionalPanel('input.municipios',
                                                                selectInput('inmueble', 'Uso del Inmueble', c('Inmuebles'=''), multiple = TRUE))
                                        )
                                 
                       ),
                       h2("Explorador de refugios"),
              hr(),
              DT::dataTableOutput('refugios')),
              # Tab para localizar refugios
              tabPanel('Ubicación de refugios',
                       leafletOutput('mexico', width = '100%', height = 800),
                       
                       absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                     draggable = TRUE, top = 100, left = "auto", right = 1000, bottom = "auto",
                                     width = 330, height = "auto",
                                     
                                     h2("Localizador de Refugios"),
                                     h6("Aquí podrás localizar los refugios por municipio. ", align = "left"),
                                     
                                     pickerInput('umunicipios', label = 'Selecciona municipios: ',
                                                 choices = c('Todos los municipios', unique(refugios_ubicacion$Municipio)), 
                                                 options = list(`live-search` = TRUE))
                                     
                                    )
                       
                      ),
              # Tab con la función que indica donde cual(es) son los refugios más cercanos
              tabPanel('Refugio más cercano',
                       leafletOutput('mexico2', width = '100%', height = 800),
                       absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                     draggable = TRUE, top = 100, left = "auto", right = 1000, bottom = "auto",
                                     width = 330, height = "auto",
                                     
                                     h2("Encuentra tu refugio más cercano"),
                                     h6("Para utilizar la aplicación es necesario primero seleccionar un punto en el mapa y seleccionar el botón Encontrar Refugio. 
                                        Da click sobre las marcas y encontrarás más información de tu localización y sobre el refugio más cercano.", align = "left"),
                                     
                                     
                                     actionButton('borrar', 'Borrar'),
                                     actionButton('encontrar', 'Encontrar Refugio'))
                       )
              )
    )
                         

# Define server logic required 
server <- function(input, output, session) {
    # Verifica el input para localizar refugios
    refugios_mun<- reactive({
        if (input$umunicipios == "Todos los municipios") {
            refugios_ubicacion
        } else {
            filter(refugios_ubicacion, Municipio == input$umunicipios)
        }
    })
    
    #Se crea mapa
    output$mexico <- renderLeaflet({
        leaflet(refugios_mun()) %>% 
            addProviderTiles(providers$CartoDB.Positron) %>% 
            setView(-105.3, 21.6, zoom = 8.2) %>% 
            addMarkers(lng=~Longitud,
                       lat = ~Latitud, 
                       popup = ~popup_text, 
                       label = ~Municipio)
    })        
    
    #Se crea otro mapa
    output$mexico2 <- renderLeaflet({
        leaflet() %>% 
            addProviderTiles(providers$CartoDB.Positron) %>% 
            setView(-105.3, 21.6, zoom = 8) 
    })    
    
    # Observe para cambiar las marcas de acuerdo al input de refugios seleccionados
    observe({
        leafletProxy('mexico', data = refugios_mun()) %>% 
            clearShapes() %>% 
            addMarkers(~Longitud,
                       ~Latitud, 
                       popup = ~popup_text
                       ) 
    })
    # Añade marcador al mapa
    observeEvent(input$mexico2_click, {
        click = input$mexico2_click
        leafletProxy('mexico2')%>%
            setView(click$lng, click$lat, zoom = 8.2) %>% 
            clearMarkers() %>% 
            clearShapes() %>% 
            addMarkers(lng = click$lng, lat = click$lat,
                       popup = paste("<h3>", 'Tu ubicación es: ', '</h3>',
                                     'Long: ', round(click$lng, 4), 'Lat: ', round(click$lat,4)))
        
    })
    
    # Encuentra refugio mas cercano
    observeEvent(input$encontrar,{
        click = input$mexico2_click
        refugio = refugios_ubicacion %>%
            rowwise() %>%
            mutate(distance = distHaversine(c(Longitud, Latitud),c(click$lng, click$lat))) %>%
            arrange(distance) %>%
            head(1)
        leafletProxy('mexico2')%>%
            setView(refugio$Longitud, refugio$Latitud, zoom = 13) %>% 
            addPolylines(lng = c(refugio$Longitud, click$lng), lat = c(refugio$Latitud, click$lat)) %>% 
            addMarkers(lng = refugio$Longitud, lat = refugio$Latitud,
                       popup  =  refugio$popup_text)
    })
    # Borra los todos los marcadores
    observeEvent(input$borrar,{
        proxy <- leafletProxy('mexico2')
        if (input$borrar){ proxy %>% clearMarkers() %>%  
                setView(-105.3, 21.6, zoom = 8.2) %>% 
                clearShapes()}
    })
    
    # Observe para filtar información de municipios
    observe({
        direccion <- if (is.null(input$municipios)) character(0) else {
            filter(refugios_ubicacion, Municipio %in% input$municipios) %>%
                `$`('Direccion') %>%
                unique() %>%
                sort()
        }
        stillSelected <- isolate(input$direccion[input$direccion %in% direccion])
        updateSelectizeInput(session, "direccion", choices = direccion,
                             selected = stillSelected, server = TRUE)
    })
    
    # Observe para filtar información de dirección y uso de inmueble
    observe({
        inmueble <- if (is.null(input$municipios)) character(0) else {
            refugios_ubicacion %>%
                filter(Municipio %in% input$municipios,
                       is.null(input$direccion) | Direccion %in% input$direccion) %>%
                `$`('Uso del Inmueble') %>%
                unique() %>%
                sort()
        }
        stillSelected <- isolate(input$inmueble[input$inmueble %in% inmueble])
        updateSelectizeInput(session, "inmueble", choices = inmueble,
                             selected = stillSelected, server = TRUE)
    })
    
    # Se filtra la información a partir de los inputs de direccion, municipio e inmueble
    output$refugios <- DT::renderDataTable({
        df <- refugios_ubicacion %>% 
            filter(
                is.null(input$municipios) | Municipio %in% input$municipios,
                is.null(input$direccion) | Direccion %in% input$direccion,
                is.null(input$inmueble) | `Uso del Inmueble` %in% input$inmueble
            )
        df <- df[-13]
        action <- DT::dataTableAjax(session, df, outputId = "refugios")
        
        DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

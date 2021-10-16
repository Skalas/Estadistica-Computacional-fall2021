# Load R packages
library(shiny)
library(shinythemes)
library(DT)
library(leaflet)
library(htmltools)
library(htmlwidgets)

#Llamamos el R script de refugios
source("refugios.R")


# Define UI
ui <- fluidPage(
  titlePanel("Página oficial para encontrar tu refugio más cercano en Nayarit"),
  navbarPage(
    ###Panel de Bienvenida
    "Refugios en Nayarit",
    tabPanel("Bienvenido", # sidebarPanel
             mainPanel(
               h2("¿Cómo navegar en la página?"),
               br(),
               h4("1. Escoge el tema que más te guste en esta pestaña, 'Choose a theme'."),
               fluidRow(
                 column(4, themeSelector(),align = "center"), align = "left"),
               h4("2. En la pestaña Ubicación por Coordenadas, podrás escoger el refugio más cercano a ti."),
               h4("3. En la pestaña Ubicación por Municipio, podrás encontrar todos los refugios de tu municipio."),
               h4("4. En caso de no conocer tus coordenadas, apóyate con el siguiente mapa:"),
               
               #Mapa con el que se obtienen las coordenadas
               verbatimTextOutput("out"),
               h4("Selecciona..."),
               # verbatimTextOutput("ubicacion_actual"),
               leafletOutput("mymap_interactive"),
               DTOutput('tbl_interactive'),
               br(),
               h5("En caso de tener alguna duda o comentario, podrás comunicarte con:"),
               h5("Adrián Tame Jacobo"),
               h5("Miguel Calvo Valente"),
               h5("Rodrigo Juárez Jaramillo"),
             )
    ),
    ###En este tabPanel, el usuario colocará las
    ###coordenadas de su ubicación para encontrar los refugios más cercanos
    tabPanel("Ubicacion por Coordenadas",
             sidebarPanel(
               tags$h3("Coordenadas de la pestaña anterior en N & W:"),
               verbatimTextOutput("out2"),
               tags$h3("Ingresa coordenadas en N & W:"),
               numericInput("lat_D", "Latitud (D):", 22, min = 0, max = 90, step = 1),
               numericInput("lat_M", "Latitud (M):", 29, min = 0, max = 60, step = 1),
               numericInput("lat_S", "Latitud (S):", 56.06, min = 0, max = 60, step = NA),
               numericInput("lon_D", "Longitud (D):", 105, min = 0, max = 180, step = 1),
               numericInput("lon_M", "Longitud (M):", 21, min = 0, max = 60, step = 1),
               numericInput("lon_S", "Longitud (S):", 41.54, min = 0, max = 60, step = NA)
             ), # sidebarPanel
             mainPanel(
               h1(""),
               h4("Ubicacion Actual"),
               verbatimTextOutput("ubicacion_actual"),
               leafletOutput("mymap"),
               DTOutput('tbl'),
             ) # mainPanel
             
    ), # TabPanel en el que se escoge un municipio y se obtienen los refugios más cercanos
    tabPanel("Ubicacion por Municipio",
             sidebarPanel(
               tags$h3("Input:"),
               selectInput("municipio", label = h3("Select box"), choices = municipios, selected = 1
               ),
             ), # sidebarPanel
             mainPanel(
               h1("Busqueda por Municipio"),
               
               h4("Selecciona..."),
               # verbatimTextOutput("ubicacion_actual"),
               leafletOutput("mymap_municipio"),
               DTOutput('tbl_municipio'),
             ) # mainPanel
    )
  ),
  p()
)

# Define server function  
server <- function(input, output) {
  #Normalizamos las coordenadas
  output$ubicacion_actual <- renderText({
    latitud_actual <- paste(input$lat_D, "º", input$lat_M, "'", input$lat_S, sep = "" )
    longitud_actual <- paste(input$lon_D, "º", input$lon_M, "'", input$lon_S,sep = "" )
    ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
    ubicacion_actual
  })
  
  output$mymap <- renderLeaflet({
    
    #Para cualquier caso, lo agregamos a un df para pasarlo al mapa
    ubicacion_actual_df <- obten_ubicacion_actual_df(input$lat_D, input$lat_M, ifelse(length(input$lat_S) == 0, .01, input$lat_S),
                                                     input$lon_D, input$lon_M, ifelse(length(input$lon_S) == 0, .01, input$lon_S))#estaria bueno parametrizarlo
    
    #Tomamos los n_closer mas cercanos
    mas_cercanos <- obten_mas_cercanos(input$lat_D, input$lat_M, input$lat_S,
                                       input$lon_D, input$lon_M, input$lon_S)
    
    #Modificamos los mas cercanos para que nos devuelva agrupados por lat y lon
    mas_cercanos <- descripciones_popups(mas_cercanos)
    
    leaflet() |>
      addTiles() |>
      addMarkers(data = mas_cercanos, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
                 popup = ~popup) |>
      addAwesomeMarkers(data = ubicacion_actual_df, lat = ~lat, lng = ~lng, popup = ~id,
                        icon  = awesomeIcons(iconColor = 'black',markerColor = "orange")) 
    
  })
  
  output$mymap_municipio <- renderLeaflet({
    
    # 20º56'15.28"	105º08'41.47"
    
    #Obtener municipios
    por_municipio <- obten_municipios(input$municipio)
    
    #Modificamos los mas cercanos para que nos devuelva agrupados por lat y lon
    por_municipio <- descripciones_popups(por_municipio)
    
    leaflet() |>
      addTiles() |>
      # addPolygons(data = nayarit_map_2,
      #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
      #             # fillColor = ~pal(log10(pop)),
      #             label = ~mun_name) |>
      addMarkers(data = por_municipio, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
                 popup = ~popup)
    
    
    
  })
  
  output$mymap_interactive <- renderLeaflet({
    leaflet() |>
      addTiles() |>
      setView(lng = -104.8947, lat = 21.5040, zoom = 8) |>  
      onRender(
        "function(el,x){
                    this.on('click', function(e) {
                        var lat = e.latlng.lat;
                        var lng = e.latlng.lng;
                        var coord = [lat, lng];
                        Shiny.onInputChange('hover_coordinates', coord)
                    });
                    
                }"
      )
  })
  
  output$tbl = renderDT(
    obten_mas_cercanos(input$lat_D, input$lat_M, input$lat_S,
                       input$lon_D, input$lon_M, input$lon_S)|>
    select(-c("Latitud_Dec", "Longitud_Dec", "dist",
                "Altitud", "No.", "Uso del Inmueble")),
    options = list(lengthChange = FALSE))
  
  
  output$tbl_municipio = renderDT(
    obten_municipios(input$municipio)|>
      select(-c("Latitud_Dec", "Longitud_Dec", "dist",
                "Altitud", "No.", "Municipio", "Uso del Inmueble")),
    options = list(lengthChange = FALSE))
  
  output$out <- renderText({
    if(is.null(input$hover_coordinates)) {
      "Mouse outside of map"
    } else {
      lat <- inverse_coordinates(input$hover_coordinates[1])
      lon <- inverse_coordinates(input$hover_coordinates[2])
      paste0("Latitud:  ", input$hover_coordinates[1],
             "     D:  ", lat[1], 
             " M: ", lat[2], 
             " S: ", lat[3], 
             "\nLongitud: ", -input$hover_coordinates[2],
             "     D: ", -lon[1], 
             " M: ", abs(lon[2]), 
             " S: ", abs(lon[3]/100))
    }
  })
  
  output$out2 <- renderText({
    if(is.null(input$hover_coordinates)) {
      "Mouse outside of map"
    } else {
      lat <- inverse_coordinates(input$hover_coordinates[1])
      lon <- inverse_coordinates(input$hover_coordinates[2])
      paste0("Latitud:  ", input$hover_coordinates[1],
             "     D:  ", lat[1], 
             " M: ", lat[2], 
             " S: ", lat[3], 
             "\nLongitud: ", -input$hover_coordinates[2],
             "     D: ", -lon[1], 
             " M: ", abs(lon[2]), 
             " S: ", abs(lon[3]/100))
    }
  })
  
  
} # server

nayarit_refugios <- corregidos

# Create Shiny object
shinyApp(ui = ui, server = server)

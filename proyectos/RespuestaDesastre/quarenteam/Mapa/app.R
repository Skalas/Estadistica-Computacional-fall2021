library(shiny)
library(leaflet)
library(shinythemes)


if (interactive()) {
  ui <- fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Mapa de refugios en Nayarit"),
    sidebarLayout(
      sidebarPanel(
        #Direccion de las coordenadas
        numericInput("lat", label = h3("Latitud:"),min = -200, max =200, value = 21.811933),
        numericInput("long", label = h3("Longitud:"),min = -200, max = 200, value = -105.262575),
        actionButton("recalc", "Show point"),
        conditionalPanel(condition = "input.tabs == 'MapaT'"),
        conditionalPanel(condition = "input.tabs == 'MapaD'")
      ),
      mainPanel(
        tabsetPanel(type = "tabs", id="tabs",
                    tabPanel(title="MapaT", leafletOutput(outputId ="mymap")),
                    tabPanel(title="MapaD", leafletOutput(outputId ="map_refugio_cercano"),
                             h3("Mapa que muestra el refugio mas cercano"),    # Third level header
                             h4("Agrega tus coordenadas"))
        )
      )
    ))
  
  server <- function(input, output, session) {
    
    iconos <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      markerColor = rango_colores
    )
    
    #Creamos íconos fifí para usar en el mapa final
    userIcons <- awesomeIconList(
      "Persona" = makeAwesomeIcon(
        icon = "user",
        markerColor = "blue",
        iconColor = "black",
        library = "fa"
      ),
      "Cercano" = makeAwesomeIcon(
        icon = "arrow-down",
        markerColor = "red",
        iconColor = "black",
        library = "fa"
      )
    )
    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addTiles() %>%  
        addAwesomeMarkers(lng = refugios$LON, 
                          lat = refugios$LAT, 
                          icon = iconos,
                          popup = paste(
                            paste('<b>','Refugio:','</b>',refugios$REFUGIO),
                            paste('<b>','Capacidad de personas:','</b>',refugios$CAPACIDAD_DE_PERSONAS),
                            paste('<b>','Teléfono:','</b>',refugios$TELEFONO),
                            sep = '<br/>'),
                          label = refugios$REFUGIO) %>%
        addLegend("bottomright", 
                  colors = c("#006666", "#669900", "deepskyblue", "#FF66FF", "darkred"), 
                  labels = c("Máximo 100", "101 a 300", "301 a 500", "501 a 1,000", "Más de 1,000"), 
                  title = "Capacidad de Personas", 
                  opacity = 1)
    })
    
    map_refugio_cercano = reactiveVal()
    myData = reactiveVal()
    
    observeEvent(input$recalc, {
      data = data.frame(x = input$long, y = input$lat)
      myData(data)
      
      refugio_mas_cercano <- refugios %>%
        mutate(Distancia = distHaversine(cbind(LON,LAT), cbind(input$long,input$lat)))%>%
        slice(which.min(Distancia))
      
      map_refugio_cercano(
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addTiles() %>%  
          addAwesomeMarkers(lng = refugio_mas_cercano$LON, 
                            lat = refugio_mas_cercano$LAT, 
                            icon = userIcons["Cercano"],
                            popup = paste(
                              paste('<b>','Refugio:','</b>',refugio_mas_cercano$REFUGIO),
                              paste('<b>','Capacidad de personas:','</b>',refugio_mas_cercano$CAPACIDAD_DE_PERSONAS),
                              paste('<b>','Teléfono:','</b>',refugio_mas_cercano$TELEFONO),
                              sep = '<br/>'),
                            label = "Refugio más cercano") %>%  
          addAwesomeMarkers(lng = input$long,  
                            lat = input$lat, 
                            icon = userIcons["Persona"],
                            label = "Usted se encuentra aquí",
                            popup = paste(
                              paste('<b>','Longitud:','</b>', input$long),
                              paste('<b>','Latitud:','</b>', input$lat),
                              sep = '<br/>'))
      )
      
    }, ignoreNULL = F)
    
    output$map_refugio_cercano = renderLeaflet({
      map_refugio_cercano()
    })
    
    output$myTable = renderTable({
      myData()
    })
  }
  
  
  
  shinyApp(ui, server)
}
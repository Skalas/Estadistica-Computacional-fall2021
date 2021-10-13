library(shiny)
library(leaflet)
library(shinythemes)
library(tidyverse)
library(geosphere)

#Cargamos los datos
refugios <- readRDS("refugios.rds")

if (interactive()) {
  ui <- fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Mapa de refugios en Nayarit"),
    sidebarLayout(
      sidebarPanel(
        actionButton("recalc", "Recalcular selección"),
        conditionalPanel(condition = "input.tabs == 'MapaT'"),
        conditionalPanel(condition = "input.tabs == 'MapaD'",
                         numericInput("lat", label = h3("Latitud:"),
                                      min = -200, max =200, value = 21.811933),
                         numericInput("long", label = h3("Longitud:"),
                                      min = -200, max = 200, value = -105.262575)),
        conditionalPanel(condition = "input.tabs == 'MapaL'",
                         selectInput(inputId="y",
                                     label="Localidad:",
                                     choices=c("ACAPONETA",           
                                               "AHUACATLAN",          
                                               "AMATLAN DE CAÑAS",    
                                               "COMPOSTELA",          
                                               "RUIZ",                
                                               "SAN BLAS",            
                                               "SAN PEDRO LAGUNILLAS",
                                               "SANTA MARIA DEL ORO", 
                                               "SANTIAGO IXCUINTLA",  
                                               "TECUALA",             
                                               "TEPIC",               
                                               "TUXPAN",              
                                               "LA YESCA",            
                                               "XALISCO",             
                                               "HUAJICORI",           
                                               "IXTLAN DEL RIO",      
                                               "JALA",                
                                               "ROSAMORADA",          
                                               "BAHIA DE BANDERAS"),
                                     selected = "ACAPONETA")
        )
      ),
      mainPanel(
        tabsetPanel(type = "tabs", id="tabs",
                    tabPanel(title="MapaT", leafletOutput(outputId ="mymap")),
                    tabPanel(title="MapaD", 
                             leafletOutput(outputId ="map_refugio_cercano"),
                             h3("Mapa que muestra el refugio mas cercano"),    
                             h4("Agrega tus coordenadas")),
                    tabPanel(title="MapaL", leafletOutput(outputId ="mymaploc"),
                             h3("Mapa que muestra los refugios en tu localidad"),    
                             h4("Selecciona tu municipio"))
        )
      )
    ))
  
  server <- function(input, output, session) {
    
    rango_colores <- c("green", "blue", "purple", 
                       "darkred", "cadetblue")[refugios$Rango_Capacidad]
    
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
                            paste('<b>','Capacidad de personas:','</b>',
                                  refugios$CAPACIDAD_DE_PERSONAS),
                            paste('<b>','Teléfono:','</b>',refugios$TELEFONOS),
                            sep = '<br/>'),
                          label = refugios$REFUGIO) %>%
        addLegend("bottomright", 
                  colors = c("#006666", "#669900", "deepskyblue", "#FF66FF", "darkred"), 
                  labels = c("Máximo 100", "101 a 300", "301 a 500", 
                             "501 a 1,000", "Más de 1,000"), 
                  title = "Capacidad de Personas", 
                  opacity = 1)
    })
    
    map_refugio_cercano = reactiveVal()
    mymaploc = reactiveVal()
    myData = reactiveVal()
    
    observeEvent(input$recalc, {
      data = data.frame(x = input$long, y = input$lat)
      myData(data)
      
      refugio_mas_cercano <- refugios %>%
        mutate(Distancia = distHaversine(cbind(LON,LAT), 
                                         cbind(input$long,input$lat)))%>%
        slice(which.min(Distancia))
      
      refugiosloc<-refugios%>%
        filter(MUNICIPIO==input$y)
      
      map_refugio_cercano(
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addTiles() %>%  
          addAwesomeMarkers(lng = refugio_mas_cercano$LON, 
                            lat = refugio_mas_cercano$LAT, 
                            icon = userIcons["Cercano"],
                            popup = paste(
                              paste('<b>','Refugio:','</b>',refugio_mas_cercano$REFUGIO),
                              paste('<b>','Capacidad de personas:','</b>',
                                    refugio_mas_cercano$CAPACIDAD_DE_PERSONAS),
                              paste('<b>','Teléfono:','</b>',refugio_mas_cercano$TELEFONOS),
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
      
      mymaploc(
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addTiles() %>%  
          addAwesomeMarkers(lng = refugiosloc$LON, 
                            lat = refugiosloc$LAT, 
                            icon = iconos,
                            popup = paste(
                              paste('<b>','Refugio:','</b>',refugiosloc$REFUGIO),
                              paste('<b>','Capacidad de personas:','</b>',
                                    refugiosloc$CAPACIDAD_DE_PERSONAS),
                              paste('<b>','Teléfono:','</b>',refugiosloc$TELEFONOS),
                              sep = '<br/>'),
                            label = refugiosloc$REFUGIO) %>%
          addLegend("bottomright", 
                    colors = c("#006666", "#669900", "deepskyblue", "#FF66FF", "darkred"), 
                    labels = c("Máximo 100", "101 a 300", "301 a 500", 
                               "501 a 1,000", "Más de 1,000"), 
                    title = "Capacidad de Personas", 
                    opacity = 1)
      )
      
    }, ignoreNULL = F)
    
    output$map_refugio_cercano = renderLeaflet({
      map_refugio_cercano()
    })
    
    output$myTable = renderTable({
      myData()
    })
    
    output$mymaploc <- renderLeaflet({
      mymaploc()
      
    })
  }
  
  
  
  shinyApp(ui, server)
}
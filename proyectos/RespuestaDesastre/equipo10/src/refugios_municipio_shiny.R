#
# Esta es un Shinydashboard para identificar refugios por municipio
# 

# Revision e instalacion de paqueterias

source("etl.R")
source("nearest_location.R")

library(shinydashboard)
library(geosphere)
library(DT)
library(leaflet)
# preparacion de datos 
# funciones y calculos iniciales

refugios_db <- etl('../data/refugios_nayarit.xlsx')

munis <- unique(refugios_db$MUNICIPIO)

min_alt <- min(refugios_db$ALTITUD)
max_alt <- max(refugios_db$ALTITUD)

# UI
header <- dashboardHeader()

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(
      "Refugios por municipio",
      tabName = "refugios_mun",
      selectInput(
        inputId = "muni_sel",
        label = "Municipio",
        choices = unique(refugios_db$MUNICIPIO)
      ),
      radioButtons(
        inputId = "capacidad",
        label = "Filtro por capacidad (# personas)",
        choices = tamanios
      )
    )
  ),

menuItem(
  "Refugios por coordeandas",
  tabName = "refugios_ubic",
  numericInput(inputId = "refugio_lat",
               label = "Valor de latitud",
               value = 0,
               min = -90,
               max = 90),
  numericInput(inputId = "refugio_alt",
               label = "Valor de longitud",
               value = 0,
               min = -180,
               max =180),
  numericInput(inputId = "num_ref_cercanos",
               label = "Número de refugios cercanos",
               value = 10,
               min = 1,
               max = 20)
  ))

body <- dashboardBody(
  
  tabBox(
    title = "Resultados búsqueda por municipio",
    tabPanel("Directorio", DT::dataTableOutput("directorio"))
  ),
  tabBox(
    title = "Mapa filtro por municipio",
    tabPanel("Mapa", leafletOutput("mimapa")) 
  ),
  tabBox(
    title = "Resultados búsqueda por coordenada",
    tabPanel("Refugios cercanos", DT::dataTableOutput("t_cercanos"))
  ),
  tabBox(
    title = "Mapa filtro por coordenada ",
    tabPanel("Mapa", leafletOutput("mimapacoor"))
)
)

ui <- dashboardPage(header, sidebar, body)


# server 
server <- function(input, output) {
  
  output$munis <- renderText({
    input$munis
  })
  
  #tabla por municipio
  output$directorio <- DT::renderDataTable({
    refugios_db %>% 
      dplyr::filter(MUNICIPIO == input$muni_sel,
                    tamanio_refugio == input$capacidad) %>% 
      select(REFUGIO, DIRECCIÓN, RESPONSABLE, TELÉFONO)
  }, options = list(aLengthMenu = c(5, 10), iDisplayLength = 5)
  )
  
  #tabla por ubicacion
  output$t_cercanos <- DT::renderDataTable({
      nearest_location(refugios_db,
                       user_long = input$refugio_alt,
                       user_lat = input$refugio_lat, 
                       input$num_ref_cercanos) %>%
      select(LONGITUD, LATITUD, DISTANCE, No., REFUGIO, DIRECCIÓN, TELÉFONO)
  }, options = list(aLengthMenu = c(5, 10), iDisplayLength = 5)
  )
  
  #mapa por municipio
  
  output$mimapa <- renderLeaflet({
    leaflet(refugios_db %>%
              filter (MUNICIPIO==input$muni_sel,
                      tamanio_refugio == input$capacidad) 
              ) %>%
    addTiles()           %>%
    addCircleMarkers(
      lng = ~LONGITUD,
      lat = ~LATITUD,        
      popup = ~paste(REFUGIO,TELÉFONO))
  })

  #mapa por coordenada
  
  output$mimapacoor <- renderLeaflet({
    leaflet(nearest_location(refugios_db,
                              user_long = input$refugio_alt,
                              user_lat = input$refugio_lat, 
                              input$num_ref_cercanos)
    ) %>%
      addTiles()           %>%
      addCircleMarkers(
        lng = ~LONGITUD,
        lat = ~LATITUD,        
        popup = ~paste(REFUGIO,TELÉFONO))  %>%
      addMarkers(lng = input$refugio_alt, lat = input$refugio_lat, popup="Ubicacion a explorar")
  })
  
}

shiny::shinyApp(ui, server)
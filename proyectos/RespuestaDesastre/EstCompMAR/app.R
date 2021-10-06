####################################
# Data Professor                   #
# http://youtube.com/dataprofessor #
# http://github.com/dataprofessor  #
####################################

# Modified from Winston Chang, 
# https://shiny.rstudio.com/gallery/shiny-theme-selector.html

# Concepts about Reactive programming used by Shiny, 
# https://shiny.rstudio.com/articles/reactivity-overview.html

# Load R packages
library(shiny)
library(shinythemes)
source("refugios.R")

prueba <- nayarit_refugios$Refugio |> head(1)

textInputRow<-function (inputId, label, value = "") 
{
  div(style="display:inline-block",
      tags$label(label, `for` = inputId), 
      tags$input(id = inputId, type = "text", value = value,class="input-small"))
}
# runApp(list(
#   ui = bootstrapPage(
#     textInputRow(inputId="xlimitsmin", label="x-min", value = 0.0),
#     textInputRow(inputId="xlimitsmax", label="x-max", value = 0.5)
#   ),
#   server = function(input, output) {}
# ))
municipios <- list("ACAPONETA"="ACAPONETA","AHUACATLAN"="AHUACATLAN",
                   "AMATLAN DE CAÑAS"="AMATLAN DE CAÑAS","COMPOSTELA" ="COMPOSTELA",
                   "COMPOSTELA"="COMPOSTELA","RUIZ"="RUIZ",
                   "SAN BLAS"="SAN BLAS", "SAN PEDRO LAGUNILLAS"="SAN PEDRO LAGUNILLAS",
                   "SAN PEDRO LAGUNILLAS"="SAN PEDRO LAGUNILLAS", 
                   "SANTA MARIA DEL ORO"="SANTA MARIA DEL ORO",
                   "SANTIAGO IXCUINTLA"="SANTIAGO IXCUINTLA",
                   "TECUALA"="TECUALA","TEPIC"="TEPIC","TUXPAN"="TUXPAN",
                   "LA YESCA"="LA YESCA","XALISCO"="XALISCO","HUAJICORI"="HUAJICORI",
                   "IXTLAN DEL RIO"="IXTLAN DEL RIO","JALA"="JALA","ROSAMORADA"="ROSAMORADA",
                   "BAHIA DE BANDERAS"="BAHIA DE BANDERAS")



  # Define UI
  ui <- fluidPage(theme = shinytheme("cerulean"),
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "My first app",
      tabPanel("Navbar 1",
               sidebarPanel(
                 tags$h3("Input:"),
                 textInput("txt1", "Latitud Actual:", ""),
                 textInput("txt2", "Longitud Actual:", ""),
                 textInput("txt3", "Municipio:", ""),
                 numericInput("lat_D", "Latitud (D):", 22, min = 0, max = 90, step = 1),
                 numericInput("lat_M", "Latitud (M):", 29, min = 0, max = 60, step = 1),
                 numericInput("lat_S", "Latitud (S):", 56.06, min = 0, max = 60, step = NA),
                 numericInput("lon_D", "Longitud (D):", 105, min = 0, max = 180, step = 1),
                 numericInput("lon_M", "Longitud (M):", 21, min = 0, max = 60, step = 1),
                 numericInput("lon_S", "Longitud (S):", 37.27, min = 0, max = 60, step = NA),
                 selectInput("Municipio:", label = h3("Select box"), choices = municipios, selected = 1
                 ),
               ), # sidebarPanel
               mainPanel(
                            h1("Header 1"),
                            
                            h4("Ubicacion Actual"),
                            verbatimTextOutput("ubicacion_actual"),

               ) # mainPanel
               
      ), # Navbar 1, tabPanel
      tabPanel("Navbar 2", "This panel is intentionally left blank"),
      tabPanel("Navbar 3", "This panel is intentionally left blank")
  
    ), # navbarPage
    leafletOutput("mymap"),
    p(),
    actionButton("recalc", "New points")
  ) # fluidPage

  
  # Define server function  
  server <- function(input, output) {
    
    output$txtout <- renderText({
      paste( input$txt1, input$txt2, prueba,sep = " " )
    })
    
    # output$lat_actual <- renderText({
    #   latitud_actual <- paste(input$lat_D, "º", input$lat_M, "'", input$lat_S, sep = "" )
    #   latitud_actual
    # })
    # output$lon_actual <- renderText({
    #   longitud_actual <- paste(input$lon_D, "º", input$lon_M, "'", input$lon_S,sep = "" )
    #   longitud_actual
    # })
    
    output$ubicacion_actual <- renderText({
      latitud_actual <- paste(input$lat_D, "º", input$lat_M, "'", input$lat_S, sep = "" )
      longitud_actual <- paste(input$lon_D, "º", input$lon_M, "'", input$lon_S,sep = "" )
      ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
      ubicacion_actual
    })
    
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  # output$mymap <- renderLeaflet({
  #   leaflet() %>%
  #     addProviderTiles(providers$Stamen.TonerLite,
  #                      options = providerTileOptions(noWrap = TRUE)
  #     ) %>%
  #     addMarkers(data = points())
  # })
  # 
  output$mymap <- renderLeaflet({
    
    latitud_actual <- paste(input$lat_D, "º", input$lat_M, "'", input$lat_S, sep = "" )
    longitud_actual <- paste(input$lon_D, "º", input$lon_M, "'", input$lon_S,sep = "" )
    ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
    
    #Para cualquier caso, lo agregamos a un df para pasarlo al mapa
    ubicacion_actual_df <- tibble(id = "Ubicacion actual",
                                  lat = ubicacion_actual[1],
                                  lng = -1*ubicacion_actual[2])
    
    aux_dist <- nayarit_refugios |> 
      mutate(x_actual = ubicacion_actual[1], y_actual = -1*ubicacion_actual[2]) |>
      select(c("Latitud_Dec", "x_actual" , "Longitud_Dec", "y_actual")) |>
      rename(x1 = Latitud_Dec, x2 = x_actual, y1 = Longitud_Dec, y2 = y_actual)
  
    nayarit_refugios$dist <- pmap_dbl(list(aux_dist$x1, aux_dist$x2, aux_dist$y1, aux_dist$y2), distancia)
    
    #Tomamos los n_closer mas cercanos
    mas_cercanos <- nayarit_refugios |>
                      arrange(dist) |>
                      head(n_closer)

    leaflet() |>
      addTiles() |>
      # addPolygons(data = nayarit_map_2,
      #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
      #             # fillColor = ~pal(log10(pop)),
      #             label = ~mun_name) |>
      addMarkers(data = mas_cercanos, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
                 popup = ~paste(Refugio, Telefono, sep="\n")) |>
      addAwesomeMarkers(data = ubicacion_actual_df, lat = ~lat, lng = ~lng, popup = ~id,
                        icon  = awesomeIcons(iconColor = 'black',markerColor = "orange"))

  })
  
  } # server
  
 
  
  
  
  
  nayarit_refugios <- corregidos

  # Create Shiny object
  shinyApp(ui = ui, server = server)

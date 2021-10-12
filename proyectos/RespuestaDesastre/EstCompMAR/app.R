####################################
# Data Professor                   #
# http://youtube.com/dataprofessor #
# http://github.com/dataprofessor  #
####################################

themeSelector <- function() {
  div(
    div(
      selectInput("shinytheme-selector", "Choose a theme",
                  c("default", shinythemes:::allThemes()),
                  selectize = FALSE
      )
    ),
    tags$script(
      "$('#shinytheme-selector')
        .on('change', function(el) {
        var allThemes = $(this).find('option').map(function() {
        if ($(this).val() === 'default')
        return 'bootstrap';
        else
        return $(this).val();
        });
        // Find the current theme
        var curTheme = el.target.value;
        if (curTheme === 'default') {
        curTheme = 'bootstrap';
        curThemePath = 'shared/bootstrap/css/bootstrap.min.css';
        } else {
        curThemePath = 'shinythemes/css/' + curTheme + '.min.css';
        }
        // Find the <link> element with that has the bootstrap.css
        var $link = $('link').filter(function() {
        var theme = $(this).attr('href');
        theme = theme.replace(/^.*\\//, '').replace(/(\\.min)?\\.css$/, '');
        return $.inArray(theme, allThemes) !== -1;
        });
        // Set it to the correct path
        $link.attr('href', curThemePath);
        });"
    )
  )
}



# Modified from Winston Chang, 
# https://shiny.rstudio.com/gallery/shiny-theme-selector.html

# Concepts about Reactive programming used by Shiny, 
# https://shiny.rstudio.com/articles/reactivity-overview.html

# install.packages("DT")

# Load R packages
library(shiny)
library(shinythemes)
library(DT)
source("refugios.R")

library(leaflet)
library(htmltools)
library(htmlwidgets)


# Define UI
ui <- fluidPage(
  navbarPage(
    "Refugios en Nayarit",
    tabPanel("Home",
             fluidRow(
               column(4, themeSelector()))
    ),
    tabPanel("Ubicacion por Coordenadas",
             sidebarPanel(
               tags$h3("Ingresa coordenadas en N & W:"),
               numericInput("lat_D", "Latitud (D):", 22, min = 0, max = 90, step = 1),
               numericInput("lat_M", "Latitud (M):", 29, min = 0, max = 60, step = 1),
               numericInput("lat_S", "Latitud (S):", 56.06, min = 0, max = 60, step = NA),
               numericInput("lon_D", "Longitud (D):", 105, min = 0, max = 180, step = 1),
               numericInput("lon_M", "Longitud (M):", 21, min = 0, max = 60, step = 1),
               numericInput("lon_S", "Longitud (S):", 37.27, min = 0, max = 60, step = NA)
             ), # sidebarPanel
             mainPanel(
               h1(""),
               h4("Ubicacion Actual"),
               verbatimTextOutput("ubicacion_actual"),
               leafletOutput("mymap"),
               DTOutput('tbl'),
             ) # mainPanel
             
    ), # Navbar 1, tabPanel
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
             
    ),
    tabPanel("Ubícate (Amiga) en el Mapa", # sidebarPanel
             mainPanel(
               h1("Busqueda por Municipio"),
               verbatimTextOutput("out"),
               h4("Selecciona..."),
               # verbatimTextOutput("ubicacion_actual"),
               leafletOutput("mymap_interactive"),
               DTOutput('tbl_interactive'),
             ) # mainPanel
             
    )
    
  ), # navbarPage
  # leafletOutput("mymap"),
  # DTOutput('tbl'),
  p()
) # fluidPage


# Define server function  
server <- function(input, output) {
  
  output$ubicacion_actual <- renderText({
    latitud_actual <- paste(input$lat_D, "º", input$lat_M, "'", input$lat_S, sep = "" )
    longitud_actual <- paste(input$lon_D, "º", input$lon_M, "'", input$lon_S,sep = "" )
    ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
    ubicacion_actual
  })
  
  output$mymap <- renderLeaflet({
    
    #Para cualquier caso, lo agregamos a un df para pasarlo al mapa
    ubicacion_actual_df <- obten_ubicacion_actual_df(input$lat_D, input$lat_M, input$lat_S,
                                                     input$lon_D, input$lon_M, input$lon_S)#estaria bueno parametrizarlo
    
    #Tomamos los n_closer mas cercanos
    mas_cercanos <- obten_mas_cercanos(input$lat_D, input$lat_M, input$lat_S,
                                       input$lon_D, input$lon_M, input$lon_S)#estaria bueno parametrizarlo
    
    
    leaflet() |>
      addTiles() |>
      addMarkers(data = mas_cercanos, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
                 popup = ~paste(Refugio, Telefono, sep="\n")) |>
      addAwesomeMarkers(data = ubicacion_actual_df, lat = ~lat, lng = ~lng, popup = ~id,
                        icon  = awesomeIcons(iconColor = 'black',markerColor = "orange")) 
    
  })
  
  output$mymap_municipio <- renderLeaflet({
    
    # 20º56'15.28"	105º08'41.47"
    
    por_municipio <- obten_municipios(input$municipio)
    
    
    leaflet() |>
      addTiles() |>
      # addPolygons(data = nayarit_map_2,
      #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
      #             # fillColor = ~pal(log10(pop)),
      #             label = ~mun_name) |>
      addMarkers(data = por_municipio, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
                 popup = ~paste(Refugio, Telefono, sep="\n"))
    
    
    
  })
  
  output$mymap_interactive <- renderLeaflet({
    
    leaflet() |>
      addTiles() |>
      setView(lng = -104.8947, lat = 21.5040, zoom = 8) |>  
      onRender(
        "function(el,x){
                    this.on('mousemove', function(e) {
                        var lat = e.latlng.lat;
                        var lng = e.latlng.lng;
                        var coord = [lat, lng];
                        Shiny.onInputChange('hover_coordinates', coord)
                    });
                    this.on('mouseout', function(e) {
                        Shiny.onInputChange('hover_coordinates', null)
                    })
                }"
      )
    
  })
  
  
  
  
  output$tbl = renderDT(
    obten_mas_cercanos(input$lat_D, input$lat_M, input$lat_S,
                       input$lon_D, input$lon_M, input$lon_S),#estaria bueno parametrizarlo
    options = list(lengthChange = FALSE))
  
  
  output$tbl_municipio = renderDT(
    obten_municipios(input$municipio)|>
      select(-c("Latitud_Dec", "Longitud_Dec", "dist",
                "Altitud", "No.", "Municipio")),
    options = list(lengthChange = FALSE))
  
  output$out <- renderText({
    if(is.null(input$hover_coordinates)) {
      "Mouse outside of map"
    } else {
      paste0("Lat: ", input$hover_coordinates[1], 
             "\nLng: ", input$hover_coordinates[2])
    }
  })
  
  
} # server






nayarit_refugios <- corregidos

# Create Shiny object
shinyApp(ui = ui, server = server)

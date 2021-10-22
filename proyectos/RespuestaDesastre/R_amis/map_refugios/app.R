#
# Dashboard para localizar los refugios más cercanos en el Estado de Nayarit
# dada una referencia de coordenadas.
# Contingencia: Huracán Patricia
# Equipo: R-amis
#
# Proyecto para la Clase de Estadística Computacional del Profesor Jaime Escalante
# ITAM, M. Data Scicence, Otoño 2021.

# Algunas partes de este Código están basadas en:
# https://github.com/garrettgman
# https://github.com/rstudio/shiny-examples/blob/master/063-superzip-example/styles.css



# =======>>> Integrar código para instalar los requirments

library(shiny)
library(leaflet)
library(rgdal)
library(DT)


r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


# ***************************   CONSTRUIR FLUID PAGE  ***************************----
# Generar las interfaces de usuario del mapa y de la tabla de datos.


ui <- fluidPage(
    titlePanel("Refugios Temporales en Nayarit. Contingencia por Huracán Patricia"),
    
    p(),

    
    navbarPage("Refugios", id="nav",position = c("fixed-bottom"), inverse = TRUE,
               theme = "bootstrap.css",

# ---------------------------   Features del Mapa   ---------------------------                                
               tabPanel("Mapa localizador",
                        div(class="outer",
                            
                            tags$head(
                              includeCSS("styles.css"),
                              includeScript("gomap.js")
                            ),
                            
                            leafletOutput("mymap", width="99%", height="87%"),
                            
                            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                          draggable = TRUE, bottom = '77px', left = '23px', width = 237, height = "auto",
                                          h3("Posición de referencia. Coord. en Grados Decimales"),
                                          numericInput("lngtd", label = "Longitud:", value = -99.12766, min = -118.35, max = -86.0, step = -1),
                                          numericInput("lttd", label = "Latitud:", value = 19.42847, min = 14.0, max = 32.5, step = 1)
                            ),
                            
                            tags$div(id="cite",
                                     'Data compiled for Proyecto:',
                                     tags$em('Localizador de Refugios en Emergencia por Huracán Patricia'),
                                     ' ITAM, M. DSc, Estadística Computacional. Equipo R-amies'
                            )
                        )
               ),
               
               
# ---------------------------   Features de Tabla   ---------------------------                   
               tabPanel("Tabla de Datos",
                        fluidRow(
                          column(3,
                                 selectInput("municipio","municipio", c("Todos los municipios"="", municips), multiple=TRUE)),
                          column(3,
                                 conditionalPanel("input.municipio",
                                                  selectInput("refugio", "refugio", c("Todos los refugios"=""), multiple=TRUE)
                                                  )),
                          column(3,
                                 conditionalPanel("input.municipio",
                                                  selectInput("servicios", "serivicios", c("Cualquiera"=""), multiple=TRUE)
                                                  )),
                          column(3,
                                 radioButtons("optDB", "Seleccione opción:",
                                              choices = list("Todos los refugios" = 1, "Refugios cercanos" = 2),selected = 1)
                                 )
                        ),
                        fluidRow(
                          column(1,
                                 numericInput("capmin", "Capacidad min", min=10, max=100, value=0)
                          ),
                          column(1,
                                 numericInput("capLim", "Capacidad lim", min=10, max=5000, value=1000)
                          )
                        ),
                        hr(),
                        DT::dataTableOutput("dfrefugios")
               ),
               conditionalPanel("false", icon("fa fa-location-arrow"))
               )
)



# ***************************   CONSTRUIR SERVER  ***************************----


# ---------------------------   Acciones en el Mapa   ---------------------------    
    server <- function(input, output, session) {
      
      ### ---> Construir el mapa:      
      output$mymap <- renderLeaflet({
        
        leaflet() %>%
          
          setView(lng = -99.12766,
                  lat = 19.4287,
                  zoom = 5.3) %>%
          
          addEasyButton(easyButton(icon="fa-duotone fa-location-arrow", title="¿Dónde estoy?",
                                   onClick=JS("function(btn, map){ map.locate({setView: true}); }") )) %>% 
          
          ### -> Proveedor
          addProviderTiles(providers$Stamen.TonerLite,
                           options = providerTileOptions(noWrap = TRUE)) %>%
          
          addPolygons(data = mx_map, fillOpacity = 0.3, smoothFactor = 0.5,
                      fillColor = "#3D85C6", color = "#A2C4C9", weight = 1) %>% 
          
          addPolygons(data = nay_map, fillOpacity = 0.3, smoothFactor = 0.5,
                      fillColor = "#D5A6BD", color = "#073763", weight = 1)
          
      })
      
      ### ---> Controlar los cambios en los inputs o click en el mapa para determinar el punto de referencia.
      observe({
        
        lngtst <- lngOk
        lattst <- latOk
        
        lng1 <- input$lngtd
        lat1 <- input$lttd
        lng2 <- ifelse(is.null(input$mymap_click$lng)==TRUE,-99.12766,input$mymap_click$lng) 
        lat2 <- ifelse(is.null(input$mymap_click$lat)==TRUE, 19.42847,input$mymap_click$lat)
        
        lngOk <<- ifelse(lng1 != lngtst,lng1,lng2)
        latOk <<- ifelse(lat1 != lattst,lat1,lat2)
        
        points <- eventReactive(c(input$lngtd,input$lttd,input$mymap_click), {
          refugios %>% ref_cerc(lngOk,latOk) %>%
            select(longitud, latitud, municipio, direccion, telefono, refugio, capacidad) %>% as_tibble()          
        }, ignoreNULL = FALSE)

        
        leafletProxy("mymap", data = refugios) %>%
          clearMarkers() %>%

          ### -> Marcadores  
          addAwesomeMarkers(data = cbind(refugios$longitud, refugios$latitud),
                            icon = icons_ref,
                            popup = paste0("Dirección: ", refugios$direccion,"; Teléfono: ", refugios$telefono),
                            label = paste0("Municipio: ",refugios$municipio, "; Refugio: ", refugios$refugio,
                                           "; Capacidad: ", refugios$capacidad)) %>%
          
          addAwesomeMarkers(data = cbind(points()$longitud,points()$latitud),
                            icon = icons_ref_n,
                            popup = paste0("Dirección: ", points()$direccion, "; Teléfono: ", points()$telefono),
                            label = paste0("Municipio: ", points()$municipio, "; Refugio: ", points()$refugio,
                                           "; Capacidad: ", points()$capacidad)) %>%
          
          addAwesomeMarkers(data = cbind(lngOk,latOk), #Punto de Referencia (rojo) 
                            icon = icons_ref_a,
                            popup = paste0("longitud: ",input$lngtd,"; latitud: ",input$lttd),
                            label = "¡Usted está aquí!"
                            )
        
        updateNumericInput(session, "lngtd", value = lngOk)
        updateNumericInput(session, "lttd", value = latOk)
      })
                      
      

### ---------------------------   Acciones en la Tabla de Datos   ---------------------------        
    
      # Mostrar infor sobre el refugio indicado en tabla de datos
      refselInfo <- function(lng,lat,ref) {
        refSelex <- refugios[refugios$refugio == ref,]
        content <- as.character(tagList(
          tags$h4("Refugio:", refSelex$refugio),
          tags$strong(HTML(
            sprintf("%s",refSelex$municipio))),
          tags$br(),
          sprintf("Teléfono: %s", refSelex$telefono), tags$br(),
          sprintf("Servicios: %s", refSelex$servicios), tags$br(),
          sprintf("Capacidad de personas: %s", refSelex$capacidad)
        ))
        leafletProxy("mymap") %>% addPopups(lng, lat, content, layerId = ref)
      }
      
      
      
      observe({
        refugios_ls <- if (is.null(input$municipio)) character(0) else {
          filter(refugios, municipio %in% input$municipio) %>%
            `$`('refugio') %>%
            unique() %>%
            sort()
        }
        stillSelected <- isolate(input$refugio[input$refugio %in% refugios_ls])
        updateSelectizeInput(session, "refugio", choices = refugios_ls,
                             selected = stillSelected, server = TRUE)
      })
      
      observe({
        servicios_ls <- if (is.null(input$municipio)) character(0) else {
          refugios %>%
            filter(municipio %in% input$municipio,
                   is.null(input$refugio) | refugio %in% input$refugio) %>%
            `$`('servicios') %>%
            unique() %>%
            sort()
        }
        stillSelected <- isolate(input$servicios[input$servicios %in% servicios_ls])
        updateSelectizeInput(session, "servicios", choices = servicios_ls,
                             selected = stillSelected, server = TRUE)
      })      
      
      
      
      observe({
        if (is.null(input$goto))
          return()
        isolate({
          mymap <- leafletProxy("mymap")
          mymap %>% clearPopups()
          dist <- 0.5
          ref <- input$goto$ref
          lat <- input$goto$lat
          lng <- input$goto$lng
          refselInfo(lng,lat,ref)
          mymap %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
        })
      })
          
      
      output$dfrefugios <- DT::renderDataTable({
#        refugiosDB <- ifelse(input$optDB == 1, refugios,points())
#        df <- refugiosDB %>%
         df <- refugios %>%
          filter(
            capacidad >= input$capmin,
            capacidad <= input$capLim,
            is.null(input$municipio) | municipio %in% input$municipio,
            is.null(input$refugio) | refugio %in% input$refugio,
            is.null(input$servicios) | servicios %in% input$servicios
          ) %>%
          mutate(Action = paste('<a class="go-map" href="" data-lat="', latitud, '" data-long="', longitud, '" data-refugio="', refugio, '"><i class="fa fa-location-arrow"></i></a>', sep=""))
        action <- DT::dataTableAjax(session, df, outputId = "dfrefugios")
        
        DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
      })
      
      }

### ---------------------------    Ejecutar la Aplicación   ---------------------------
shinyApp(ui = ui, server = server)






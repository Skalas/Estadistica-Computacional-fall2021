#
# Dashboard para localizar los refugios más cercanos
# Contingencia: Huracán Patricia
# Equipo: R-amis
#


# =======>>> Integrar código para instalar los requirments

library(shiny)
library(leaflet)
library(rgdal)
library(DT)


r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


# Generar el Fluid Page sobre para generar el flukjo de interacción del mapa y la localización de este punto.
ui <- fluidPage(

    # Panel para 
    titlePanel("Refugios Temporales en Nayarit. Contingencia por Huracán Patricia"),
    
    p(),

    
    navbarPage("Refugios", id="nav",position = c("fixed-bottom"), inverse = TRUE,
               theme = "bootstrap.css",
               
               tabPanel("Mapa localizador",
                        div(class="outer",
                            
                            tags$head(
                              # Include our custom CSS
                              includeCSS("styles.css")
                            ),
                            
                            # 
                            leafletOutput("mymap", width="99%", height="87%"),
                            
                            # Shiny versions prior to 0.11 should use class = "modal" instead.
                            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                          draggable = TRUE, bottom = '77px', left = '23px', width = 237, height = "auto",
                                          h3("Posición de referencia. Coord. en Grados Decimales"),
                                          numericInput("lngtd", label = "Longitud:", value = -99.12766, min = -118.35, max = -86.0, step = -1),
                                          numericInput("lttd", label = "Latitud:", value = 19.42847, min = 14.0, max = 32.5, step = 1),
                            ),
                            
                            tags$div(id="cite",
                                     'Data compiled for Proyecto:',
                                     tags$em('Localizador de Refugios en Emergencia por Huracán Patricia'),
                                     ' ITAM, M. DSc, Estadística Computacional. Equipo R-amies'
                            )
                        )
               ),
               
               
               
               tabPanel("Data explorer",
                        DT::dataTableOutput("refugios")
               ),
               
               
               
               )

)




# Construir el Server:

server <- function(input, output, session) {

      points <- eventReactive(c(input$lngtd,input$lttd), {
        refugios %>% ref_cerc(input$lngtd,input$lttd) %>%
          select(longitud, latitud) %>% as.matrix()
        
        }, ignoreNULL = FALSE)
      
      
      points <- eventReactive(input$mymap_click, {
        refugios %>% ref_cerc(ifelse(is.null(input$mymap_click$lng)==TRUE,input$lngtd,input$mymap_click$lng),
                              ifelse(is.null(input$mymap_click$lat)==TRUE,input$lttd,input$mymap_click$lat)) %>%
          select(longitud, latitud, direccion, telefono, refugio, capacidad) %>% as_tibble()
      }, ignoreNULL = FALSE)
      
       
    output$mymap <- renderLeaflet({
      leaflet() %>%
        
        setView(lng = ifelse(is.null(input$mymap_click$lng)==TRUE,input$lngtd,input$mymap_click$lng),
                lat = ifelse(is.null(input$mymap_click$lat)==TRUE,input$lttd,input$mymap_click$lat),
                zoom = 5.3) %>%
        
        addEasyButton(easyButton(icon="fa-duotone fa-location-arrow", title="¿Dónde estoy?",
          onClick=JS("function(btn, map){ map.locate({setView: true}); }")
        

          )) %>% 
        
        
        addProviderTiles(providers$Stamen.TonerLite,
                         options = providerTileOptions(noWrap = TRUE)) %>%
        addAwesomeMarkers(data = cbind(refugios$longitud, refugios$latitud),
                          icon = icons_ref,
                          popup = paste0("Dirección: ", refugios$direccion,"; Teléfono: ",
                                         refugios$telefono),
                          label = paste0("Refugio: ",refugios$refugio, "; Capacidad: ",
                                         refugios$capacidad)) %>%
        addAwesomeMarkers(data = cbind(points()$longitud,points()$latitud),
                          icon = icons_ref_n,
                          popup = paste0("Dirección: ", points()$direccion,"; Teléfono: ",
                                         points()$telefono),
                          label = paste0("Refugio: ",points()$refugio, "; Capacidad: ",
                                         points()$capacidad)) %>%
        addAwesomeMarkers(data = cbind(ifelse(is.null(input$mymap_click$lng)==TRUE,input$lngtd,input$mymap_click$lng),
                                       ifelse(is.null(input$mymap_click$lat)==TRUE,input$lttd,input$mymap_click$lat)), #Punto de Referencia (rojo)
                          icon = icons_ref_a,
                          popup = paste0("longitud: ",input$lngtd,"; latitud: ",input$lttd),
                          label = "Usted está aquí!"
                          )
        
    })
    
    observe(
    DT::datatable(data = refugios %>% ref_cerc(ifelse(is.null(input$mymap_click$lng)==TRUE,input$lngtd,input$mymap_click$lng),
                                               ifelse(is.null(input$mymap_click$lat)==TRUE,input$lttd,input$mymap_click$lat)))
    )
    
    }

# Ejecutar la Aplicación
shinyApp(ui = ui, server = server)






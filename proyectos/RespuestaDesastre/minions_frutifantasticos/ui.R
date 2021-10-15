library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(leaflet)
library(DT)
library(ggplot2)
library(plotly)
library(googleway)

dashboardPage(
    skin = "black",
    dashboardHeader(
        title = "Refugios Temporales",
        tags$li(a(href = 'https://www.facebook.com/proteccioncivilnay/',
                  img(src = 'bomberos-logo.jpg',
                      title = "Bomberos", height = "30px"),
                  style = "padding-top:10px; padding-bottom:10px;"),
                class = "dropdown"),
        tags$li(a(href = 'https://www.facebook.com/proteccioncivilnay/',
                  img(src = 'protect-civil.png',
                      title = "Protección Civil", height = "30px"),
                  style = "padding-top:10px; padding-bottom:10px;"),
                class = "dropdown"),
        disable = F
        ),
    dashboardSidebar(
        loadingLogo(
            href = 'https://www.nayarit.gob.mx/', 
            src = 'nayarit-logo.png', 
            #loadingsrc = "https://i.imgur.com/pKV7YwY.gif",
            loadingsrc = 'https://c.tenor.com/7NX24XoJX0MAAAAC/loading-fast.gif',
            height = "70%",
            width = "100%"),
        tags$br(),
        menuItem("Buscar", icon = icon(name = "search"), startExpanded = T,
            shinyWidgets::prettyRadioButtons(
                inputId = "button_coord",
                label = "Seleccione método",
                choices = c("Dirección" = "dir", 
                            "GPS" = "gps", 
                            "Coordenadas" = "coord"),
                selected = "coord",
                bigger = T,
                animation = "smoth"
                ),
            
            conditionalPanel("input.button_coord == 'dir'",
                shinyWidgets::textInputIcon(
                    inputId = "calle", 
                    label = "Ingrese ubicación", 
                    placeholder = "Calle num, C.P.",
                    icon =  icon("map"),
                    width = "95%"
                )
             ),
            conditionalPanel("input.button_coord == 'gps'",
                tags$h4("Instrucciones:"),
                tags$h5("Utilice el botón de GPS ubicado en
                        el mapa para detectar su ubicación")
            ),
            conditionalPanel("input.button_coord == 'coord'",
                numericInputIcon("lng", label = "Longitud", value = -104.898492, step = 0.01, 
                              icon = icon("arrow-left")),
                numericInputIcon("lat", label = "Latitud", value = 21.507156, step = 0.01, 
                              icon = icon("arrow-up"))
            ),
            shinyWidgets::prettyRadioButtons(
                inputId = "medio_transporte",
                label = "Seleccione método de transporte",
                choices = c("Automóvil" = "driving", 
                            "Bicicleta" = "bicycling", 
                            "Caminando" = "walking",
                            "Transporte Público" = "transit"),
                selected = "driving",
                bigger = T,
                animation = "smoth"
            )
        ),
        tags$br(),
        actionButton(inputId = "search", label = "Localizar", icon = icon("fas fa-street-view"))
    ),
    dashboardBody(
        tags$head(tags$style(HTML(
            ".navbar-custom-menu {
                float: left!important;
            }
            "))),
        useSweetAlert(theme = "dark"),
        fluidRow(
            column(
                width = 5,
                box(
                    width = NULL,
                    solidHeader = T,
                    leafletOutput("map", height = 350)
                )
            ),
            column(
                width = 7,
                box(
                    width = NULL,
                    solidHeader = T,
                    div(dataTableOutput("table", height = 350), style = "font-size:70.0%")
                )
            )
        ),
        fluidRow(
            column(
                width = 5,
                box(
                    title = "Número de refugios en municipios colindantes y sus localidades",
                    width = NULL,
                    #background = "black",
                    solidHeader = T,
                    plotOutput("count_refugios_mun_loc", height = 300)
                )
            ),
            column(
                width = 7,
                box(
                    title = "Disponibilidad y ocupación por refugio",
                    width = NULL,
                    solidHeader = T,
                    plotlyOutput("availability_plot", height = 300)
                )
            )
        )
    )
)
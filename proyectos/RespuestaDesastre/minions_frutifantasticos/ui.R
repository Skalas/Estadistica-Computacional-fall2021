library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(leaflet)
library(DT)
library(ggplot2)
library(plotly)

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
            #loadingsrc = 'http://northerntechmap.com/assets/img/loading-dog.gif',
            #loadingsrc = "https://i.imgur.com/pKV7YwY.gif",
            loadingsrc = 'https://c.tenor.com/7NX24XoJX0MAAAAC/loading-fast.gif',
            height = "70%",
            width = "100%"),
        tags$br(),
        menuItem("Filtros", tabName = "Filtros", icon = icon("filter")),
        tags$br(),
        menuItem("Gráficas", tabName = "Graficas", icon = icon("fas fa-chart-bar"),
            radioButtons(
                inputId = "button_plot", 
                label = "Tipo de gráfico",
                choices = c("Municipio", "Refugios", "Ocupación Gral"),
                selected = "Municipio"
            )),
        tags$br(),
        menuItem("Buscar", icon = icon(name = "search"), startExpanded = T,
            shinyWidgets::prettyRadioButtons(
                inputId = "button_coord",
                label = "Seleccione método",
                choices = c("Dirección" = "dir", 
                            "GPS" = "gps", 
                            "Coordenadas" = "coord"),
                selected = "gps",
                bigger = T,
                animation = "smoth"
                ),
            conditionalPanel("input.button_coord == 'coord'",
                numericInputIcon("lng", label = "Longitud", value = -104.898492, step = 0.01, 
                                 icon = icon("arrow-left")),
                numericInputIcon("lat", label = "Latitud", value = 21.507156, step = 0.01, 
                                 icon = icon("arrow-up"))
            ),
            conditionalPanel("input.button_coord == 'dir'",
                shinyWidgets::textInputIcon(
                    inputId = "calle", 
                    label = "Ingrese ubicación", 
                    placeholder = "Calle num, cp",
                    icon =  icon("map"),
                    width = "95%"
                )
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
                    title = "Número de refugios en municipios y localidades cercanos",
                    width = NULL,
                    background = "black",
                    solidHeader = T,
                    plotOutput("circle_bar_plot", height = 300)
                )
            )
        )
        
    )
)
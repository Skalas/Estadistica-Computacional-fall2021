library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(leaflet)
library(DT)

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
            href = 'http://mycompanyishere.com', 
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
                inputId = "boton_plot", 
                label = "Tipo de gráfico",
                choices = c("Municipio", "Refugios", "Ocupación Gral"),
                selected = "Municipio"
            )),
        tags$br(),
        menuItem("Buscar", icon = icon(name = "search"), startExpanded = T,
            numericInput("lng", label = "Longitud", value = -104.898492, step = 0.000001),
            numericInput("lat", label = "Latitud", value = 21.507156, step = 0.000001)
        ),
        tags$br(),
        actionButton(inputId = "search", label = "Buscar coordenadas", icon = icon("map-pin"))
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
                    leafletOutput("map", height = 400)
                )
            ),
            column(
                width = 7,
                box(
                    width = NULL,
                    solidHeader = T,
                    div(dataTableOutput("table", height = 400), style = "font-size:57.5%")
                )
            )
        )
        
    )
)
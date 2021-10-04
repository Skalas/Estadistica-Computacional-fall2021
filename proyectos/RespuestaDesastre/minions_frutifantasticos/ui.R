library(shiny)
library(shinydashboard)
library(leaflet)


dashboardPage(
    skin = "red",
    dashboardHeader(
        title = "Explorer Dashboard",
        tags$li(a(href = 'http://www.company.com',
                  img(src = 'bomberos-logo.jpg',
                      title = "Bomberos", height = "30px"),
                  style = "padding-top:10px; padding-bottom:10px;"),
                class = "dropdown"),
        tags$li(a(href = 'http://www.company.com',
                  img(src = 'protect-civil.png',
                      title = "Protección Civil", height = "30px"),
                  style = "padding-top:10px; padding-bottom:10px;"),
                class = "dropdown")
        ),
    dashboardSidebar(
        loadingLogo(
            href = 'http://mycompanyishere.com', 
            src = 'nayarit-logo.png', 
            loadingsrc = 'http://northerntechmap.com/assets/img/loading-dog.gif',
            height = "70%",
            width = "100%")
    ),
    dashboardBody(
        tags$head(tags$style(HTML(
            ".navbar-custom-menu {
                float: left!important;
            }
            "))),
        fluidRow(
            column(
                width = 9,
                box(
                    width = NULL,
                    solidHeader = T,
                    leafletOutput("map", height = 500)
                )
            )
        )
        
    )
)
library(shiny)
library(dplyr)
library(nycflights13)
library(DT)


ui <- fluidPage(
                                        # Título
    titlePanel("Geyser Data"),
                                        # Un sidebar con su slider.
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),
        mainPanel(
            plotOutput("distPlot"),
            h2('Flights'),
            dataTableOutput('table')
        )
    ))
server <- function(input, output){
    output$distPlot <- renderPlot({
        print("corrí el plot")
        x    <- faithful[, 2]  # Geyser data
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             main='Histograma!', ylab = 'Frecuencia')
    })
    output$table <- renderDataTable({
        print("corri la tabla")
        flights
    })
}

shinyApp(ui = ui, server = server)

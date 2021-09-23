shinyUI(fluidPage(
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
  )
))

function(input, output, session) {
  output$distPlot <- renderPlot({
    x    <- faithful[, 2]  # Geyser data
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         main='Histograma!', ylab = 'Frecuencia')
  })
  output$table <- renderDataTable({
      flights
  })
}

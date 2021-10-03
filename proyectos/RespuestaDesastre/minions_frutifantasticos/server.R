library(shinydashboard)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$map <- renderLeaflet({

        # generate bins based on input$bins from ui.R
        map <- leaflet() %>% 
            addTiles() %>% 
            setView(lng = -99.14, lat = 19.4, zoom = 11)
        
        return(map)

    })

})

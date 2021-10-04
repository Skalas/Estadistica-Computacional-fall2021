library(shinydashboard)
library(leaflet)

shinyServer(function(input, output) {

    output$map <- renderLeaflet({

        map <- leaflet() %>% 
            addTiles() %>% 
            setView(lng = -99.14, lat = 19.4, zoom = 11) %>% 
            addTiles(group = "OSM (default)") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellital") %>%
            addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
            addScaleBar("bottomleft") %>% 
            addLayersControl(
                baseGroups = c("OSM", "Satellital", "CartoDB"),
                options = layersControlOptions(collapsed = T)
                ) %>%
            addEasyButton(easyButton(
                icon="fa-globe", 
                title="Zoom to Level 1",
                onClick=JS("function(btn, map){ map.setZoom(5); }"))) %>% 
            addMiniMap(
                toggleDisplay = TRUE, 
                width = 90, 
                height = 90, 
                minimized = T
                )
        
        return(map)

    })

})

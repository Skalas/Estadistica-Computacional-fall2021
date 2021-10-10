library(shinydashboard)
library(leaflet)
library(purrr)
library(DT)

shinyServer(function(input, output, session) {

    output$map <- renderLeaflet({
        
        opacity = 0.9
        split_data <- split(data, data$uso_cat)
        
        map <- data %>% 
            leaflet() %>% 
            addTiles() %>% 
            fitBounds(lng1 = shp@bbox[1, 1], lng2 = shp@bbox[1, 2],
                      lat1 = shp@bbox[2, 1], lat2 = shp@bbox[2, 2]) %>% 
            addTiles(group = "OSM (default)") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellital") %>%
            addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
            addPolygons(
                color = "black", 
                fillColor = "transparent", 
                weight = 2,
                dashArray = "5",
                highlightOptions = highlightOptions(
                    weight = 4,
                    color = "black",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = FALSE),
                data = shp
            )
        
        names(split_data) %>%
            walk(function(category) {
                map <<- map %>%
                    addCircleMarkers(
                        data = split_data[[category]],
                        lng =~ lng, 
                        lat =~ lat, 
                        radius =~ sqrt(capacidad)/7,
                        label =~  refugio,
                        weight = 1,
                        #color = "black",
                        color =~ pal(uso_cat),
                        fillOpacity = opacity,
                        group = category)
            })
        
        map %<>%
            addScaleBar("bottomright") %>% 
            addLayersControl(
                baseGroups = c("OSM", "Satellital", "CartoDB"),
                overlayGroups = names(split_data),
                options = layersControlOptions(collapsed = T)) %>%
            addEasyButton(easyButton(
                icon= "fa-globe", 
                title= "Zoom to Level 1",
                onClick = JS("function(btn, map){ map.setZoom(5); }"))) %>% 
            addMiniMap(
                toggleDisplay = TRUE, 
                width = 90, 
                height = 90, 
                minimized = T) %>% 
            addLegend(
                title = "Uso de inmueble",
                position = "bottomleft",
                pal = pal,
                values = c("EDUCACION", "EJIDAL", "GOBIERNO MUNICIPAL", "OTROS"),
                opacity = opacity
            )
        
        if (input$search != 0){
            isolate({
                input$search
                map %<>% addMarkers(lng = input$lng, lat = input$lat)
            })
        }
        return(map)
    })
    
    output$table <- renderDataTable({
        datatable(
        data,
        rownames = F,
        extensions = c('Buttons', 'Scroller', "FixedColumns"),
        options = list(
            scroller = TRUE,
            scrollX = TRUE,
            scrollY = 330,
            fixedColumns = list(leftColumns = 2),
            #pageLength = 5,
            dom = 'Bfrtip',
            buttons = c('copy', 'excel', 'pdf', 'print'),
            initComplete = JS(
                "function(settings, json) {",
                "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                "}")
        ))
    })
    
    observeEvent(input$search, {
        sendSweetAlert(
            session = session,
            title = "Éxito!!",
            text = "Ubicación localizada",
            type = "success"
        )
    })
    

})

library(shinydashboard)
library(leaflet)
library(purrr)
library(DT)

shinyServer(function(input, output, session) {

    output$map <- renderLeaflet({
        
        opacity = 1
        split_data <- split(data, data$uso_cat)
        
        map <- data %>% 
            leaflet() %>% 
            addTiles() %>% 
            addTiles(group = "OSM (default)") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellital") %>%
            addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
            addPolygons(
                color = "black", 
                fillColor = "transparent", 
                weight = 2,
                data = shp
            )
        
        names(split_data) %>%
            walk(function(category) {
                map <<- map %>%
                    addCircleMarkers(
                        data = split_data[[category]],
                        lng =~ lng, 
                        lat =~ lat, 
                        radius =~ log(capacidad_de_personas),
                        label =~  refugio,
                        weight = 1,
                        color = ~ pal(uso_cat),
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
    
    output$table <- renderDataTable(
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
        )
    )
    
    observeEvent(input$search, {
        sendSweetAlert(
            session = session,
            title = "Éxito!!",
            text = "Ubicación localizada",
            type = "success"
        )
    })
    

})

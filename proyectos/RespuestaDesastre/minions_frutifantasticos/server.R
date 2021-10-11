library(shinydashboard)
library(leaflet)
# devtools::install_github("tomroh/leaflegend")
library(leaflegend)
library(leaflet.extras)
library(purrr)
library(DT)
library(geosphere)

shinyServer(function(input, output, session) {
    
    datum <- reactive({
        
        df <- data
        if(input$search == 0) return(df)
        
        input$search
        isolate({
            df %<>% 
                distance_compute(
                    lat_input = input$lat, 
                    lon_input = input$lng) %>% 
                arrange(distance)
            
            return(df)
        })
    })

    output$map <- renderLeaflet({
        
        opacity = 0.9
        split_data <- split(datum(), datum()$uso_cat)
        
        map <- datum() %>% 
            leaflet() %>% 
            addTiles() %>% 
            fitBounds(lng1 = shp_mun@bbox[1, 1], lng2 = shp_mun@bbox[1, 2],
                      lat1 = shp_mun@bbox[2, 1], lat2 = shp_mun@bbox[2, 2]) %>% 
            addTiles(group = "OSM (default)") %>%
            addProviderTiles("Esri.WorldImagery", group = "Satellital") %>%
            addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
            addPolygons(
                color = "black", 
                fillColor = "lightblue", 
                weight = 2,
                dashArray = "4",
                highlightOptions = highlightOptions(
                    weight = 3,
                    color = "black",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = FALSE),
                data = shp_mun
            )
        
        names(split_data) %>%
            walk(function(category) {
                
                labels <- sprintf(
                    "<strong> Refugio: </strong> <br/> %s <br/>
                     <strong> Servicios: </strong> <br/> %s <br/>
                     <strong> Capacidad: </strong> <br/> %s personas <br/>
                     <strong> Disponibilidad: </strong> <br/> %g personas <br/>
                     <strong> Responsable: </strong> <br/> %s <br/>
                     <strong> Teléfono: </strong> <br/> %s <br/>",
                    tolower(split_data[[category]]$refugio), 
                    tolower(split_data[[category]]$servicios), 
                    tolower(split_data[[category]]$capacidad), 
                    split_data[[category]]$disponibilidad,
                    tolower(split_data[[category]]$responsable), 
                    tolower(split_data[[category]]$telefono)) %>% 
                    map(htmltools::HTML)
                
                map <<- map %>%
                    addCircleMarkers(
                        data = split_data[[category]],
                        lng =~ lng, 
                        lat =~ lat, 
                        radius =~ sqrt(capacidad)/7 + 1,
                        label = labels,
                        labelOptions = labelOptions(
                            style = list("font-weight" = "normal", padding = "3px 8px"),
                            textsize = "11px",
                            direction = "auto"),
                        weight = 1,
                        #color = "black",
                        color =~ pal(uso_cat),
                        fillOpacity = opacity,
                        group = category)
            })
        
        if (input$search != 0){
            input$search
            isolate({
                
                map %<>% 
                    addAwesomeMarkers(
                        lng = input$lng, 
                        lat = input$lat,
                        icon = icons("blue"),
                        label = "Mi ubicación"
                    ) %>% 
                    addAwesomeMarkers(
                        lng = datum()[1,]$lng,
                        lat = datum()[1,]$lat + 0.00025,
                        icon = icons("green"),
                        label = "Refugio más cercano"
                    )
            })
        }
        
        map %<>%
            addScaleBar("bottomright") %>% 
            addLayersControl(
                baseGroups = c("CartoDB", "OSM", "Satellital"),
                overlayGroups = names(split_data),
                options = layersControlOptions(collapsed = T)) %>%
            addEasyButton(easyButton(
                icon= "fa-globe", 
                title= "Zoom to Level 1",
                onClick = JS("function(btn, map){ map.setZoom(5); }"))) %>% 
            addMeasure(
                position = "topright",
                primaryLengthUnit = "meters",
                secondaryLengthUnit = "kilometers",
                primaryAreaUnit = "sqmeters",
                localization = "es",
                activeColor = "navy",
                completedColor = "navy"
            ) %>% 
            addMiniMap(
                toggleDisplay = TRUE, 
                width = 85, 
                height = 85, 
                minimized = T) %>% 
            addLegendFactor(
                title = "Uso de inmueble",
                position = "bottomleft",
                pal = pal,
                values = c("Educación", "Ejidal", "Gobierno Municipal", "Otros"),
                opacity = opacity,
                width = 11,
                height = 11,
                shape = "circle"
            ) %>% 
            addControlGPS(
                options = gpsOptions(
                    position = "topleft", 
                    activate = TRUE,
                    autoCenter = TRUE, 
                    maxZoom = 60,
                    setView = F
                )
            )
        
        return(map)
    })
    
    output$table <- renderDataTable({
        
        datatable(
        datum(),
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
    
    observe(print(input$map_gps_located))

})






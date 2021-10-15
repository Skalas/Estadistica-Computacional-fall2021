library(shinydashboard)
library(leaflet)
# devtools::install_github("tomroh/leaflegend")
library(leaflegend)
library(leaflet.extras)
library(purrr)
library(DT)
library(geosphere)
library(ggplot2)
library(plotly)
library(rgeos)

shinyServer(function(input, output, session) {
    
    origin <- reactive({
        
        lat_long <- c(lat = 21.507156, lng = -104.898492)
        
        if (input$search != 0){
            input$search
            isolate({
                
                if(input$button_coord == "gps"){
                    
                    lat <- input$map_gps_located$coordinates$lat
                    lng <- input$map_gps_located$coordinates$lng
                    lat_long <- c(lat = lat, lng = lng)
                    
                }else if(input$button_coord == "dir"){
                    
                    request <- googleway::google_geocode(
                        address = input$calle,
                        language = "es",
                        region = "mx",
                        key = "AIzaSyC4CWHxehmC8_z-solHZ8YqKIGdNn6Bh3g"
                    )
                    
                    if(request$status == "OK"){
                        lat_long <- c(lat = request$results$geometry$location$lat,
                          lng = request$results$geometry$location$lng)
                    }else lat_long <- c(lat = 21.507156, lng = -104.898492)
                        
                    print(lat_long)
                    
                    }else({
                        lat_long <- c(lat = input$lat, lng = input$lng)
                    })
                })
        }
        
        return(lat_long)
    })
    
    datum <- reactive({
        
        df <- data
        if(input$search == 0) return(df)
        
        input$search
        isolate({
            df %<>% 
                distance_compute(
                    lat_input = origin()["lat"], 
                    lon_input = origin()["lng"]) %>% 
                arrange(distance) %>% 
                mutate(rankid = row_number()) %>% 
                relocate(distance, .after = no) %>% 
                relocate(rankid, .before = distance) %>% 
                relocate(no, .after = last_col())

            return(df)
        })
    })
    
    output$map <- renderLeaflet({
        
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
                fillColor = "transparent", 
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
                            textsize = "10px",
                            direction = "auto"),
                        weight = 1,
                        #color = "black",
                        color =~ pal(uso_cat),
                        fillOpacity = opacity,
                        group = category,
                        layerId =~ no
                    )
            })
        
        if (input$search != 0){
            input$search
            isolate({
                
                destination <- c(datum()[1,]$lat, datum()[1,]$lng)
                
                dir <- google_directions(
                    key = "AIzaSyC4CWHxehmC8_z-solHZ8YqKIGdNn6Bh3g",
                    origin = origin(),
                    destination = destination,
                    region = "mx",
                    mode = input$medio_transporte,
                    simplify = T,
                    alternatives = F
                )

                ruta <- dir$routes$overview_polyline$points %>%
                    decode_pl() %>%
                    as_tibble()
                
                map %<>%
                    addAwesomeMarkers(
                        lng = ruta$lon[1],
                        lat = ruta$lat[1],
                        icon = icons("blue"),
                        label = "Mi ubicación"
                    ) %>%
                    addAwesomeMarkers(
                        lng = datum()[1,]$lng,
                        lat = datum()[1,]$lat + 0.000075,
                        icon = icons("green"),
                        label = "Refugio más cercano"
                    ) %>%
                    addPolylines(lng = ruta$lon, lat = ruta$lat, color = "blue")
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
                minimized = F) %>% 
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
        class = "display nowrap",
        extensions = c('Buttons', 'Scroller', "FixedColumns"),
        selection = "single",
        options = list(
            stateSave = TRUE,
            #scroller = TRUE,
            scrollX = TRUE,
            #scrollY = 330,
            pageLength = 8,
            lengthMenu = c(8, 10, 15, 20),
            fixedColumns = list(leftColumns = 3),
            dom = 'lBfrtip',
            buttons = c('copy', 'excel', 'pdf', 'print'),
            initComplete = JS(
                "function(settings, json) {",
                "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                "}")
        )) 
    })
    
    output$circle_bar_plot <- renderPlot({
        
        circle_bar_plot(
            data = datum(), 
            shape = shp_mun, 
            municipio = if_else(
                condition = is.null(prev_row()$municipio), 
                true = "Tepic", 
                false = prev_row()$municipio
            )
        )
    })
    
    prev_row <- reactiveVal()
    
    observeEvent(input$search, {
        sendSweetAlert(
            session = session,
            title = "Éxito!!",
            text = "Ubicación localizada",
            type = "success"
        )
    })
    
    observeEvent(input$table_rows_selected, {
        
        row_selected = datum()[input$table_rows_selected,]
        
        mun = row_selected$municipio
        
        proxy <- leafletProxy('map')
        #adj <- rownames(mtx_adj)[mtx_adj[, rownames(mtx_adj) == mun]]
        #partial_shp <- shp_mun[shp_mun@data$municipio %in% adj, ]
        
        proxy %>%
            addAwesomeMarkers(
                layerId = as.character(row_selected$no),
                lng=row_selected$lng, 
                lat=row_selected$lat,
                icon = my_icon
            ) %>% 
            addPolygons(
                layerId = as.character(row_selected$no),
                #data = shp_mun[mtx_adj[rownames(mtx_adj) == mun,],],
                data = shp_mun[shp_mun@data$municipio == mun,],
                color = "black",
                fillColor = "blue",
                weight = 2,
                dashArray = "4",
                highlightOptions = highlightOptions(
                    weight = 3,
                    color = "black",
                    dashArray = "",
                    #fillOpacity = 0.5,
                    bringToFront = F
                )
            )
        
        if(!is.null(prev_row())) {
            proxy %>% 
                removeMarker(layerId = as.character(prev_row()$no)) %>% 
                removeShape(layerId = prev_row()$no)
        }
        prev_row(row_selected)
    })
    
    observeEvent(input$map_marker_click, {
        clickId <- input$map_marker_click$id
        dataTableProxy("table") %>%
            selectRows(which(datum()$no == clickId)) %>%
            selectPage(ceiling(
                datum()[which(datum()$no == clickId),]$rankid / input$table_state$length)
            )
    })

    # observe(print(prev_row()))
    # observe(print(input$map_gps_located$coordinates))
})






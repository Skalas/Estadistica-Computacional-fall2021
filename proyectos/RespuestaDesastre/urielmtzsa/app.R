##### Instalación y carga de paqueterías

# Librerías a utilizar. Si no se tiene alguna, se instala.
pack_u<-c("rstudioapi","readxl","dplyr","knitr","kableExtra","ggplot2","tidyr","leaflet","rgdal","shiny","osrm","rdist")
pack_u_installed<-pack_u %in% installed.packages()
pack_u_uninstalled<-pack_u[pack_u_installed==FALSE]
install.packages(pack_u_uninstalled)
lapply(pack_u, require, character.only = TRUE)

##### Establecer directorio de trabajo. 

# Se estable el directorio de trabajo como la carpeta donde se encuentre el archivo .R
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) 

##### Ejecución de ETL

source(paste(getwd(),"/proyecto1_etl.R",sep=""))



shinyApp(
  
  

ui <- fluidPage(
  titlePanel(title = span(column(10,br(),strong("REFUGIOS NAYARIT")),column(2,img(src ="nayarit.png", height = 70)))),
  br(),br(),br(),br(),
  wellPanel(p(em("Utiliza el siguiente mapa para seleccionar tu ubicación actual y así poder localizar el refugio más cercano a ti. Si conoces tus coordenadas actuales introdúcelas como latitud y longitud. Si no es así, ¡no te preocupes!, sólo marca en el mapa cuál es tu ubiación actual.")),
  p(em("El mapa te mostrará una sugerencia de la ruta que puedes tomar para llegar al refugio más cercano a tu ubicación. Además, en el panel izquierdo podrás ver información relacionada al refugio."))),
  fluidRow(
    column(4,
           wellPanel(
             numericInput("Latitud", "Latitud", 21.49,20.5,23,0.1),
             numericInput("Longitud", "Longitud", 104.89,103.5,106,0.1)
           ),
           wellPanel(
             h4("Municipio:"),
             verbatimTextOutput("municipio"),
             h4("Refugio:"),
             verbatimTextOutput("nombre"),
             h4("Dirección:"),
             verbatimTextOutput("direccion"),
             h4("Distancia:"),
             verbatimTextOutput("distancia"),
             h4("Tiempo:"),
             verbatimTextOutput("tiempo"),
             h4("Capacidad personas:"),
             verbatimTextOutput("capacidad"),
             h4("Responsable:"),
             verbatimTextOutput("responsable"),
             h4("Contacto(s):"),
             verbatimTextOutput("telefonos"),
             h4("Servicios disponibles:"),
             verbatimTextOutput("servicios"),
             h4("Uso del inmueble:"),
             verbatimTextOutput("uso")
           )
    ),
    column(8,
           leafletOutput("mymap"),
           br(),
           h4(strong("¿Quieres saber qué otros refugios hay en tu municipio?")),
           selectInput("select_municipio", "",
                       unique(df$municipio),
                       unique(df$municipio)[1]),
           plotOutput("bar",height ="500")
           )
    )
             
),



server <- function(input, output,session){
  
  
  
  lat_point <- reactive({
    validate(
      need(is.numeric(input$Latitud),"Por favor, sólo introduce valores numéricos")
    )
    input$Latitud
  })
  
  
  
  lon_point <- reactive({
    need(is.numeric(input$Longitud),"Por favor, sólo introduce valores numéricos")
    input$Longitud
  })
  

  
  ##### Carga de polígonos del estado de Nayarit
  mexico <- readOGR(dsn = "./estados", layer = "states", encoding = "UTF-8")
  nayarit<-which(mexico@data$NOM_ENT=="Nayarit")
  map <- mexico@polygons[[nayarit]]
  pal <- colorBin("Reds",log(df$capacidad_personas))
  refugios_popup <- paste0("<strong>Municipio: </strong>", 
                           df$municipio, 
                           "<br><strong>Refugio: </strong>", 
                           df$refugio,
                           "<br><strong>Capacidad de personas: </strong>",
                           df$capacidad_personas,
                           "<br><strong>Latitud: </strong>",
                           round(df$latitud_val,2),
                           "<br><strong>Longitud: </strong>",
                           round(df$longitud_val,2),
                           "<br><strong>Altitud: </strong>",
                           round(df$altitud,2)
                           )
  
  
  
  ##### Creación de mapa  
  output$mymap <-renderLeaflet({
    leaflet(data = map) %>%
    addTiles() %>%
    addPolygons(
      fillOpacity = 0.3, 
      smoothFactor = 0.5,
      color = "#BDBDC3", 
      weight = 5) %>%
    addCircleMarkers(-df$longitud_val,df$latitud_val,
                     radius=3,
                     color=pal(log(df$capacidad_personas)),
                     popup=refugios_popup) 
  })
  
  
  
  ##### Interacción cuando se hace click en el mapa
  observeEvent(input$mymap_click, {
    
    click <- input$mymap_click
    click_lat <- click$lat
    click_long <- click$lng
    
    updateNumericInput(session, "Latitud", "Latitud", click_lat,20.5,23,0.1)
    updateNumericInput(session, "Longitud", "Longitud", -click_long,103.5,106,0.1)
  })
  

  
  ##### Interacción cuando se actualizan las coordenadas
  observe({
    
    ##### Seleccionar los  10 puntos más cercanos a la ubicación (distancia manhattan)
    x1<-df %>% select(longitud_val,latitud_val) %>% mutate(longitud_val=-longitud_val)
    x2<-data_frame(longitud_val=c(-lon_point()),latitud_val=c(lat_point()))
    x1<-as.data.frame(cdist(x1,x2,metric="manhattan"))
    names(x1)<-c("distance")
    x1<-cbind(df,x1) 
    x1<-x1  %>% top_n(-10,wt=distance) %>%  select(no,longitud_val,latitud_val) %>% 
      mutate(longitud_val=-longitud_val) 
    
    ##### Seleccionar los 5 puntos más cercanos a ubicación (con OSRM)
    x2<-data_frame(no=c("Point"),longitud_val=c(-lon_point()),latitud_val=c(lat_point()))
    x1 <- osrmTable(src=x1,dst=x2,measure = c('duration', 'distance'),osrm.profile = "car")
    x1_distance<-as.data.frame(x1$distances)
    x1_duration<-as.data.frame(x1$durations)
    x1_distance$no<-rownames(x1_distance)
    x1_duration$no<-rownames(x1_duration)
    
    ##### Escoger la ruta del refugio más cercano
    x1<-x1_distance %>% top_n(-5,wt=Point)
    x1<-merge(x1,x1_duration,by="no",suffixes=c("_distance","_duration"),all.x=TRUE,all.y=FALSE)
    x1<-merge(x1,df,by="no",all.x=TRUE,all.y=FALSE)
    x1<-x1 %>% arrange(Point_distance) 
    x1_p<-x1 %>%  select(no,longitud_val,latitud_val) %>% 
      mutate(longitud_val=-longitud_val) 
    
    ruta <- osrmRoute(src = x1_p[1,], dst = x2[1,], overview = "full", returnclass="sp")
    
    ##### ACTUALIZACIÓN DE MAPA
    leafletProxy('mymap') %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircleMarkers(-df$longitud_val,df$latitud_val,
                       radius=3,
                       color=pal(log(df$capacidad_personas)),
                       popup=refugios_popup) %>%
    addAwesomeMarkers(lng=-lon_point(),lat=lat_point(),popup="<strong>¡Estás aquí! </strong>",
                      icon=awesomeIcons(markerColor = "darkblue")) %>%
    addPolylines(data=ruta,color = "darkblue") %>%
      addMeasure(primaryLengthUnit = "kilometers",
                 secondaryLengthUnit = "meters")
    
    
    
    ##### ACTUALIZACIÓN DE INFORMACIÓN DE REFUGIO MÁS CERCANO
    output$municipio <- renderText({x1[1,"municipio"]  })
    output$nombre <- renderText({x1[1,"refugio"]  })
    output$direccion <- renderText({x1[1,"direccion"]  })
    output$distancia <- renderText({paste(x1[1,"Point_distance"]/1000," km en vehículo",sep="")  })
    output$tiempo <- renderText({paste(x1[1,"Point_duration"]," minutos en vehículo",sep="")  })
    output$capacidad <- renderText({x1[1,"capacidad_personas"]  })
    output$responsable <- renderText({x1[1,"responsable"]  })
    output$telefonos <- renderText({x1[1,"telefonos"]  })
    output$servicios <- renderText({x1[1,"servicios"]  })
    output$uso <- renderText({x1[1,"uso_inmueble"]  })
    updateSelectInput(session, "select_municipio", "", unique(df$municipio),x1[1,"municipio"]) 
  })
  
  
  
  ##### Gráfico de barras de municipios
  output$bar <- renderPlot({
    df %>%
      filter(municipio==input$select_municipio) %>%
      arrange(desc(capacidad_personas)) %>%
      mutate(refugio=paste(refugio," (",round(latitud_val,2),",",round(longitud_val,2),")",sep="")) %>%
      ggplot(data = .,  aes(y=reorder(refugio,(capacidad_personas)), x=capacidad_personas)) + 
      geom_bar(stat="identity",fill="dodgerblue") +
      labs(title="",y="Refugio", x = "Capacidad de personas")+
      geom_text(aes(label = capacidad_personas, hjust = -0.2)) +
      theme_classic()
  })
  
  
  
}
)





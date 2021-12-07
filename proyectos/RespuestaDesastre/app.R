
############################################################
#### Parte 1: Requisitos ###################################
############################################################
#renv::init() #####FAVOR DE PONER OPCION 1
source("1_packages.R")
source("2_functions.R")
source("3_prueba_eval.R")
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

############################################################
#### Parte 2: UI ###########################################
############################################################

ui <- fluidPage(
  # En esta parte se optó por trabajar con dos paneles: uno izquierdo y uno principal
  # En el izquierdo se recolecta y verifica la información del usuario
  # En el principal se hace un render de la información del refugio y refugios más cercanos.
  
  titlePanel("Encuentra tu refugio más cercano"),
  sidebarLayout(
    # Aqui se diseña el panel izquierdo
    sidebarPanel(
      # Estas son las cajas de donde se optiene información
      textInput("calle", "Calle", "Rio Hondo"),
      textInput("num", "Número", "1"),
      textInput("mun", "Municipio", "Alvaro Obregón"),
      actionButton("go", "Detecta mi ubicación"), #Boton GO
      actionButton("go2", "Detecta mi refugio más cercano"), #Boton GO2
      # Se renderea un mapa de la ubicación del usuario
      leafletOutput("mymap1"),
    ),
    
    # Aqui se diseña el panel principal
    mainPanel(
      # Se redacta una breve descripción del servicio para el usuario
      
      p("Con esta aplicacion puedes encontrar tu refugio más cercano."),
      br(),
      p("En primer lugar, encuentra tu ubicación en el cuadro de la izquierda vaciando la calle, número y municipio en el que te encuentras y dando click en \"Detecta mi ubicación\". Te aparecerá un mapa donde se indica tu ubicación actual. Si tu ubicación es la correcta oprime el segundo botón \"Detecta mi refugio más cercano\". Este segundo botón te mostrara un mapa de la ubicación del refugio más cercano y te mostrara información relevante como la dirección, los telefonos, la capacidad del refugio, entre otros aspectos."),
      br(),
      p("Tu refugio más cercano se encuentra aquí:"),
      # Se imprime una tabla con info del refugio mas cercano
      fluidRow(
        column(8,
               tableOutput('table')
        )),
      # Se imprime una mapa del refugio mas cercano
      leafletOutput("mymap2"),
      br(),
      # Se muestra info de refugios en el municipio
      p("Asimismo, también puedes checar estos otros refugios en tu localidad"),
      br(),
      # Se imprimen mapas con los refugios del mun
      leafletOutput("mymap3"),
      br(),
      # Se muestra una tabla interactiva con info de los refugios del mun
      
      fluidRow(
        column(8,
               DT::dataTableOutput('table2')
        ))
    ))
  
    
)

############################################################
#### Parte 3: SERVER ###########################################
############################################################

server <- function(input, output, session) {
  #_____________   #PARTE 3.1 FUNCIONES INTERACTIVAS
  #_____________
  # En esta parte se diseñan las funciones interactivas que se activan al oprimir los botones de go y go2
  # Se explotan todas las funciones que se encuentran en 2_functions.R
  
    mi_ubi <- eventReactive(input$go, {
      #extrae la ubicacion para mostrarla en el mapa
      ubi<-paste(input$calle, input$num , input$mun, sep=" ")
      ubi<-geocode(ubi)
      paint_map(ubi[[1]],ubi[[2]])
    })
    
    mi_refugio <- eventReactive(input$go2, {
      #extrae la ubicacion para mostrar un mapa con el refugio
      ubi<-paste(input$calle, input$num , input$mun, sep=" ")
      ubi<-geocode(ubi)
      ref<-motor_refugio_cercano(abs(ubi[[1]]),abs(ubi[[2]]))
      paint_map(-ref[[1]],ref[[2]])
    })
    
    mitabla<-eventReactive(input$go2,{ 
      #simpelemente muestra el data frame filtrado por el id del refugio
      ubi<-paste(input$calle, input$num , input$mun, sep=" ")
      ubi<-geocode(ubi)
      ref<-motor_refugio_cercano(abs(ubi[[1]]),abs(ubi[[2]]))
      data %>% 
        filter(id==ref[[3]]) %>% 
        select(-coordN,-coordW,-altitud,-w,-n) 
      })
    
    mis_refugios <- eventReactive(input$go2, {
      #extrae la ubicacion para mostrar un mapa con los refugios del mismo municipio
      ubi<-paste(input$calle, input$num , input$mun, sep=" ")
      ubi<-geocode(ubi)
      ref<-motor_refugio_cercano(abs(ubi[[1]]),abs(ubi[[2]]))
      motor_refugios_municipio_map(ref[[4]])
    })
    
    mistablas<-eventReactive(input$go2,{ 
      #simpelemente muestra el data frame filtrado por el mun del refugio
      ubi<-paste(input$calle, input$num , input$mun, sep=" ")
      ubi<-geocode(ubi)
      ref<-motor_refugio_cercano(abs(ubi[[1]]),abs(ubi[[2]]))
      data %>% 
        filter(municipio==ref[[4]]) %>% 
        select(-coordN,-coordW,-altitud,-w,-n) 
    })
    
  #_____________   #PARTE 3.2 RENDER DE FUNCIONES INTERACTIVAS
  #_____________  
    
    # En esta seccion cada funcion anterior se muestra en cada espacio definido en el UI.
    
    output$mymap1 <- renderLeaflet({
           mi_ubi()
    })
    
    output$mymap2 <- renderLeaflet({ 
      mi_refugio()
     
    })
    
    output$table <- renderTable({ mitabla()
      })
    
    output$mymap3 <- renderLeaflet({ 
      mis_refugios()
      
    })
    
    output$table2 <- DT::renderDataTable({ mistablas()
    },server=TRUE)
    
    
}

shinyApp(ui, server)



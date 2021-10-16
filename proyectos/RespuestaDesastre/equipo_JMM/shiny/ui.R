shinyUI(fluidPage(


# Formato para las pestañas del menú superior  -----------------  
  navbarPage("Localización de Centros de Refugio del Estado de Nayarit", id="main", 
             
    tags$style(HTML("
                     .tabbable > .nav > li > a                  {background-color: lightblue;  color:black}
                     .tabbable > .nav > li > a[data-value='Entradas'] {background-color: lightblue;   color:black}
                     .tabbable > .nav > li > a[data-value='Centros cercanos'] {background-color: lightblue;  color:black}
                     .tabbable > .nav > li > a[data-value='Todos centros'] {background-color: lightblue;  color:black}
                     .tabbable > .nav > li > a[data-value='Infraestructura'] {background-color: lightblue;  color:black}
                     .tabbable > .nav > li[class=active]    > a {background-color: black; color:white}
                    ")),
 
# Interfaz de salida  -----------------         
    tabsetPanel( 
# Primer pestaña  -----------------     
      tabPanel("Entradas", 
# Cajas de entrada de texto y botón de localización -----------------              
          sidebarLayout(
                 sidebarPanel(
               h1("Elige un Centro"),
               numericInput("latitud", 
                            label = h4("Latitud en decimal (14.53333 , 32.71667) :") , 
                            value =20.67879, 
                            step = 0.00001,
                            min = 20.60333,
                            max = 23.08444,
                            width = "400px"),
               numericInput(inputId ="longitud", 
                            label = h4("Longitud en decimal (-118.45000 , -86.70000) :"), 
                            value =-104.67879,
                            step = 0.00001,
                            min = -105.72690,
                            max = -103.72080,
                            width = "400px"),
               numericInput(inputId ="n_cercanos", 
                            label = h4("Número de centros a localizar:"), 
                            value = 6,
                            step = 1,
                            min = 1,
                            max = 20,
                            width = "250px"),
               actionButton("boton_loc", "Localiza")
                 ),
# Muestra el mapa de Nayarit con los centros de refugio -----------------                  
               mainPanel(
               leafletOutput("mapa", height = "750px")
                 
               )
               )
               
      ),
# Muestra segunda pestaña con coordenadas seleccionadas y tabla de centros  -----------------  
      tabPanel("Centros cercanos", 
               h2('Dato seleccionado'),
               h4('Latitud'),
               verbatimTextOutput("latitud"),
               h4('Longitud'),
               verbatimTextOutput("longitud"),
               h2('Centros Nayarit'),
               DT::DTOutput('cen_cercanos'),
      ),
# Muestra tercera pestaña con tabla de todos los centros  ----------------
      tabPanel("Todos centros", 
               h2('Centros Nayarit'),
               DT::DTOutput("tablaDT"),
      ), 
# Muestra mapa de carreteras en Nayarit  ----------------
      tabPanel( "Infraestructura",
                br(),br(), 
                "Mapa de la infraestructura de transporte de Nayarit",
                hr(),
                br(),
                img(src="infra_tran_nayarit.png", align = 'center', height = 1200, width = 800)
                
      )
    )
  ) 
  
))


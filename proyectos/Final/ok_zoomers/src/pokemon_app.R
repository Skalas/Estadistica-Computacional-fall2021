## shiny app Pokemon
# Con base en https://medium.com/swlh/two-way-analytics-with-r-shiny-and-pokemon-e9eae225fd46

rm(list = ls())

library(shiny)
library(plotly)
library(tidyr)
library(dplyr)
library(RPostgres)
library(DBI)

# Conexión
con <- dbConnect(RPostgres::Postgres()
                 , host='localhost'
                 , port='5432'
                 , dbname='postgres'
                 , user='postgres'
                 , password='pokemon')
dbExistsTable(con, "pokemon_")
# TRUE


# Read in data 

# setwd("/data/" )
pokemon_data_r <- dbGetQuery(con, 'Select * from pokemon_')
colnames(pokemon_data_r) <- tolower(colnames(pokemon_data_r))
classif_data_r <- read.csv("../data/resultados.csv")

# UI 
ui <- navbarPage(selected = "Seleccionar Pokemon",
                 
                 # insertamos logo Pokemon
                 #### no funciona 2021-12-01 - revisar
                 title=div(tags$img(src="poke_ball.png", height =50),
                            style="margin-top: -25px; padding:10px"),
                 
                 # titulo de la ventana
                 windowTitle="Shiny app Pokemon - Computo Estadistico",
                 
                 # Panel de graficos
                 tabPanel("Seleccionar Pokemon", 
                          fluidPage(

                            # Tab comparar pokemon
                            fluidRow(
                              column(width=10,
                                     titlePanel("Seleccionar Pokemones para comparacion"),
                                     div(p('Escoger Pokemon 1 y Pokemon 2'),style='width:150px; display:inline'))
                            ),
                            # Sidebar con tipos de pokemon (electric, water, etc.) 
                            sidebarLayout(
                              sidebarPanel(
                                selectInput('poke_type1',
                                            'Tipo Pokemon 1:',
                                            choices = unique(pokemon_data_r$type1)[order(unique(pokemon_data_r$type1))],
                                            selected=1),
                                selectInput('poke_type2',
                                            '   Generacion:',
                                            choices = unique(pokemon_data_r$generation)[order(unique(pokemon_data_r$generation))],
                                            selected=1),
                                uiOutput('pokemon_ui'),
                                selectInput('poke_type3',
                                            'Tipo Pokemon 2',
                                            choices = unique(pokemon_data_r$type1)[order(unique(pokemon_data_r$type1))],
                                            selected=2),
                                selectInput('poke_type4',
                                            '   Generacion:',
                                            choices = unique(pokemon_data_r$generation)[order(unique(pokemon_data_r$generation))],
                                            selected=2),
                                uiOutput('pokemon_ui2'),
                              ),
                            
                              # Mostrar graficos 
                              mainPanel(
                                div(plotlyOutput('bar_comp'),style="background: margin-top:-85x; border-style: groove; padding-right:10px"),
                               )
                            )
                          )),
                 tabPanel("Display Clasificacion",
                          fluidPage(
                            fluidRow(
                              column(width=10,
                                     titlePanel("Clasificacion multivariada de Pokemones"),
                                     div(p('Escoger grupos a mostrar'),style='width:150px; display:inline'))
                            ),
                            sidebarLayout(
                              sidebarPanel(
                                # selectInput('select_method',
                                #             'Metodo:',
                                #             choices = c("cl_kmeans",	"cl_agglomerative",
                                #                         "cl_kmedoids",	"cl_kmeans_t", "cl_agglomerative_t", "cl_kmedoids_t"),
                                #             selected = 1),
                                selectInput('class_type1',
                                            'Clusters:',
                                            choices =  unique(classif_data_r$cl_kmeans)[order(unique(classif_data_r$cl_kmeans))],
                                            selected=0:5, multiple = TRUE),
                                uiOutput('cluster_ui'),
                                
                                
                              ),
                              mainPanel(
                                div(plotlyOutput('class_poke'),style="background: margin-top:-85x; border-style: groove; padding-right:10px"),
                            )
                            )
                          )
                 )
)  





#  Server Function
server <- function(input, output) {
  # Mostrar Pokemon por tipo seleccionado
  output$pokemon_ui <- renderUI({
    choices <- pokemon_data_r %>% 
      filter(type1 == input$poke_type1,
             generation == input$poke_type2) %>% 
      select(name) %>%  pull()
    selectInput("pokemon_name",
                "   Escoger pokemon:",
                choices = choices)
  })
  output$pokemon_ui2 <- renderUI({
    choices <- pokemon_data_r %>% 
      filter(type1 == input$poke_type3,
             generation == input$poke_type4) %>% 
      select(name) %>%  pull()
    selectInput("pokemon_name2",
                "   Escoger otro pokemon:",
                choices = choices)
  })
  
  # output$cluster_ui <- renderUI({
  #   choices <- classif_data_r %>% 
  #     filter(cl_kmeans %in% input$class_type1) %>% 
  #     select(name) %>%  pull()
  #   selectInput("pokemon_name2",
  #               "   Escoger otro pokemon:",
  #               choices = choices)
  # })
  
  # Filtrar datos para pokemones seleccionados
  selected_pokemon <- reactive({
    poke_selection <- pokemon_data_r[which(pokemon_data_r$name == input$pokemon_name),]
  })
  selected_pokemon2 <- reactive({
    poke_selection <- pokemon_data_r[which(pokemon_data_r$name == input$pokemon_name2),]
  })

  # generar bd para graficos compare
  output$bar_comp <- renderPlotly({
    req(input$pokemon_name)
    df <- selected_pokemon() %>%
      select(attack,sp_attack, defense, sp_defense,
             height_m, weight_kg, 
             hp, speed, base_egg_steps, base_happiness,	capture_rate) %>%
      mutate(base_egg_steps = base_egg_steps/100) %>% 
      gather("Stat", "Value") %>%
      mutate(side = input$pokemon_name)
    df2 <- selected_pokemon2() %>%
      select(attack,sp_attack, defense, sp_defense,
             height_m, weight_kg, 
             hp, speed, base_egg_steps, base_happiness,	capture_rate) %>%
      mutate(base_egg_steps = base_egg_steps/100) %>% 
      gather("Stat", "Value") %>%
      mutate(side = input$pokemon_name2)
    
    df_full <- rbind(df,df2)
    df_full$Value <- as.numeric(df_full$Value)
    
    l <- list(
      font = list(
        family = "sans-serif",
        size = 12,
        color = "#000"),
      x = -.001, y = 0, orientation = 'h')
    
    # plot 1
    df_full1 <- df_full %>% filter(Stat == "attack" | Stat == "sp_attack")
    
    plot1 <- df_full1 %>% 
      ggplot(aes(x = Stat, y = Value, fill = side,
                 text = paste0(ifelse(side== input$pokemon_name, 
                                      input$pokemon_name, input$pokemon_name2),
                               '<br>', Stat, ': ', Value
                 ))) + 
      geom_bar(stat = "identity", width = 0.75, position = "dodge") +
      #coord_flip() +#Make horizontal instead of vertical
      scale_x_discrete(limits = df_full1$Stat) +
      scale_y_continuous(breaks = seq(-300, 300, 50),
                         labels = abs(seq(-300, 300, 50))) +
      labs(x = "", y = "") +
      ggtitle(paste0("Estadisticas ",input$pokemon_name, " vs. ", input$pokemon_name2)) +
      theme(legend.position = "bottom",
            legend.title = element_blank(),
            plot.title = element_text(hjust = 0.5),
            panel.background = element_rect(fill =  "white"),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.text.x = element_text(angle = 25, vjust = 0.5, hjust=1)) + 
      scale_fill_manual(values=c('#2a75bb','#ffcb05'))
    
    
    # plot 2
    df_full2 <- df_full %>% filter(Stat == "defense" | Stat == "sp_defense")

    plot2 <- df_full2 %>%
      ggplot(aes(x = Stat, y = Value, fill = side,
                 text = paste0(ifelse(side==input$pokemon_name, 
                                      input$pokemon_name, input$pokemon_name2),
                               '<br>', Stat, ': ', abs(Value)
                 ))) +
      geom_bar(stat = "identity", width = 0.75, position = "dodge") +
      #coord_flip() +#Make horizontal instead of vertical
      scale_x_discrete(limits = df_full2$Stat) +
      scale_y_continuous(breaks = seq(-300, 300, 50),
                         labels = abs(seq(-300, 300, 50))) +
      labs(x = "", y = "") +
      ggtitle(paste0("Estadisticas ",input$pokemon_name, " vs. ", input$pokemon_name2)) +
      theme(legend.position = "bottom",
            legend.title = element_blank(),
            plot.title = element_text(hjust = 0.5),
            panel.background = element_rect(fill =  "white"),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.text.x = element_text(angle = 25, vjust = 0.5, hjust=1)) +
      scale_fill_manual(values=c('grey','seagreen3'))

    # # plot 3
    df_full3 <- df_full %>% filter(Stat == "height_m" | Stat == "weight_kg" | Stat == "speed")

    plot3 <- df_full3 %>%
      ggplot(aes(x = Stat, y = Value, fill = side,
                 text = paste0(ifelse(side== input$pokemon_name, 
                                      input$pokemon_name, input$pokemon_name2),
                               '<br>', Stat, ': ', abs(Value)
                 ))) +
      geom_bar(stat = "identity", width = 0.75, position = "dodge") +
      #coord_flip() +#Make horizontal instead of vertical
      scale_x_discrete(limits = df_full3$Stat) +
      scale_y_continuous(breaks = seq(-300, 300, 50),
                         labels = abs(seq(-300, 300, 50))) +
      labs(x = "", y = "") +
      ggtitle(paste0("Estadisticas ",input$pokemon_name, " vs. ", input$pokemon_name2)) +
      theme(legend.position = "bottom",
            legend.title = element_blank(),
            plot.title = element_text(hjust = 0.5),
            panel.background = element_rect(fill =  "white"),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.text.x = element_text(angle = 25, vjust = 0.5, hjust=1)) +
      scale_fill_manual(values=c('red3','blue3'))

    # plot 4
    df_full4 <- df_full %>%
      filter(Stat == "hp" | Stat == "base_egg_steps" | Stat == "base_happiness" | Stat == "capture_rate")

    plot4 <- df_full4 %>%
      ggplot(aes(x = Stat, y = Value, fill = side,
                 text = paste0(ifelse(side== input$pokemon_name, 
                                      input$pokemon_name, input$pokemon_name2),
                               '<br>', Stat, ': ', abs(Value)
                 ))) +
      geom_bar(stat = "identity", width = 0.75, position = "dodge") +
      #coord_flip() +#Make horizontal instead of vertical
      scale_x_discrete(guide = guide_axis(n.dodge=3)) + #limits = df_full4$Stat,
      scale_y_continuous(breaks = seq(-300, 300, 50),
                         labels = abs(seq(-300, 300, 50))) +
      labs(x = "", y = "") +
      ggtitle(paste0("Estadisticas ",input$pokemon_name, " vs. ", input$pokemon_name2)) +
      theme(legend.position = "bottom",
            legend.title = element_blank(),
            plot.title = element_text(hjust = 0.5),
            panel.background = element_rect(fill =  "white"),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.text.x = element_text(angle = 25, vjust = 0.5, hjust=1)) +
      scale_fill_manual(values=c('yellow3','orange'))

     fig <- subplot(style(plot1, showlegend = FALSE),
                    style(plot2, showlegend = FALSE),
                    style(plot3, showlegend = FALSE),
                    style(plot4, showlegend = FALSE), 
                    nrows = 2, margin =  0.05) %>%
      layout(title = paste0("Estadisticas ",input$pokemon_name, " vs. ", input$pokemon_name2))
    fig
  })
  
  # Filtrar datos 
  # selected_method <- reactive({
  #   method_selection <- classif_data_r[, input$select_method ]
  # })
  selected_cluster <- reactive({
    cluster_selection <- classif_data_r[which(classif_data_r$cl_kmeans %in% input$class_type1),]
  })
  
  # generar bd para graficos cluster
  
  output$class_poke <- renderPlotly({
    
    df <- selected_cluster() %>% 
      select(d1,d2,cl_kmeans) %>% 
      mutate(clasificacion = factor(cl_kmeans))
    
    plot5 <- df %>% 
      ggplot(aes(x = d1, y = d2, fill = clasificacion)) + 
      geom_jitter()
    
    ggplotly(plot5, tooltip = c("text"))
    
  })
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)

function(input, output, session) {

# Verifica que la entrada de latitud y longitud esten en el rango  -----------------
# guarda los valores selecionados de latitud y longitud -----------------
       lat_react <- eventReactive(input$boton_loc,{
         validate(
           need(as.numeric(input$latitud) >= 14.53333, 'Valor fuera de rango, rango valido para territorio nacional (14.53333 , 32.71667) '),
           need(as.numeric(input$latitud) <= 32.71667, 'Valor fuera de rango, rango valido para territorio nacional (14.53333 , 32.71667) ')
         )
                as.numeric(input$latitud)
        })
       
       long_react <- eventReactive(input$boton_loc,{
         validate(
           need(as.numeric(input$longitud) >= -118.45, 'Valor fuera de rango, rango valido para territorio nacional (-118,45 , -86.7) '),
           need(as.numeric(input$longitud) <= -86.7, 'Valor fuera de rango, rango valido para territorio nacional (-118,45 , -86.7) ')
         )
            as.numeric(input$longitud)
       })
   
    
# Detecta el evento de boton de seleciona  ----------------- 
  num_muns <- eventReactive(input$boton_loc, {
    as.numeric(input$n_cercanos)
  })
 
# Activa las Salidas  -----------------  
  output$latitud <- renderPrint({ lat_react() })
  output$longitud <- renderPrint({ 
        long_react() })
  
  output$tablaDT <- DT::renderDT({gen_tabla(dta, FALSE)})
  

  output$cen_cercanos <- DT::renderDT({calcula_dist(long_react(),
                                                      lat_react(),
                                                      num_muns()) %>% 
                         gen_tabla(TRUE) })
 
    output$mapa <- renderLeaflet({
    crea_mapa_closest(dta,
                      long_react(),
                      lat_react(),
                      num_muns())
    
  })
  
}



# Verifica si se requiere instalar los paquetes ----------------------

if(!require("DT")) install.packages("DT")
if(!require("shiny")) install.packages("shiny")
if(!require("leaflet")) install.packages("leaflet")
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("geosphere")) install.packages("geosphere")


library(DT)
library(shiny)
library(leaflet)
library(tidyverse)
library(geosphere)


# Cargar en background ----------------------------------------------------

dta <- readRDS('../rds/data_clean.rds') %>% 
  select(-num)

mtx_coord <- dta %>% 
  select(long, lat) %>% 
  as.matrix()

# Ingresamos la función de calcular distancia "calcula_dist" ------------------------------------------------------------

calcula_dist <- function(long,lat,nrows = 6){
  
  input_point <- c(long, lat)
  
  
  dta_dist <- dta %>% 
    mutate(distancia = distCosine(input_point, mtx_coord)) %>% 
    arrange(distancia) %>% 
    select(refugio,municipio, direccion, tel, lat, long, distancia) %>%  #por definir info a mostrar
    distinct(lat, long, .keep_all = TRUE) %>% 
    head(nrows) #por definir num de renglones a mostrar
  
  dta_dist
  
}

gen_tabla <- function(df, contains_dist = FALSE){
  tabla <- DT::datatable(df %>% 
                          as_tibble(),
                        options = list(
                          pageLength = 10,
                          language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
                          autoWidth = TRUE, 
                          scrollX = TRUE,
                          escape = T)) %>% 
    DT::formatRound(c("lat", "long"), 4) 
  
  if(contains_dist) tabla <- tabla %>% DT::formatRound(c("distancia"),0)
  
  tabla
}

# Creamos el mapa --------------------------------------------------------------------


crea_mapa_base <- function(df){
  
  m <- leaflet() %>% 
    addTiles() %>% 
    addAwesomeMarkers(lng = ~long, lat = ~lat, data = df, popup = ~refugio,
                      icon = awesomeIcons(),
                      popupOptions = popupOptions(closeOnClick = TRUE))
  
  m
  
}

addUserMarker <- function(mapa_base, long = -105.1, lat = 22.5){
  
  m <- mapa_base %>% 
    addCircleMarkers(lng = long, lat = lat, radius = 15, color = "red",
                     popup = "User Input")
  
  m
  
}

addClosestMarkers <- function(mapa_base, long = -105.1, lat = 22.5, n_closest = 6){
  
  df_closest <- calcula_dist(long, lat, n_closest)
  
  m <- mapa_base %>% 
    addCircleMarkers(lng = ~long, lat = ~lat, data = df_closest, radius = 15, color = "green")
  
  m
}


crea_mapa_closest <- function(df, long, lat, n_closest){
  
  df %>% 
    crea_mapa_base() %>% 
    addUserMarker(long, lat) %>% 
    addClosestMarkers(long, lat, n_closest)
  
}

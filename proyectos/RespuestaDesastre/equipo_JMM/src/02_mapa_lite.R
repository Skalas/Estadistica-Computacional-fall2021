if(!require("leaflet")) install.packages("leaflet")

library(leaflet)

source('src/01_algoritmo_distancia.R')

dta <- readRDS('rds/data_clean.rds')

# m <- leaflet() %>% 
#   addTiles() %>% 
#   addAwesomeMarkers(lng = ~long, lat = ~lat, data = dta, popup = ~refugio,
#                     icon = awesomeIcons(),
#                     popupOptions = popupOptions(closeOnClick = TRUE)) %>% 
#   addCircleMarkers(lng = -105.1, lat = 22.5, radius = 20, color = "red", popup = "User Input")
# 
# m

# Hacer función -----------------------------------------------------------

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

# Test --------------------------------------------------------------------

dta %>% 
  crea_mapa_closest(-105.1,22.5,10)

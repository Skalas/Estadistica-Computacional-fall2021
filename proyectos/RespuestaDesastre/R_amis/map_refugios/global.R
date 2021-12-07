
### -------   Cargar librerias y Archivos source   -------

library(dplyr)
library(shiny)
library(leaflet)
library(rgdal)
library(DT)
library(htmltools)
library(htmlwidgets)


source("./src/utils/utils.R"  , encoding = 'UTF-8')

### -------   DB Refugios   -------
refugios <- readRDS('./data/refugios_nayarit.Rds')
municips <- refugios %>% select(municipio) %>% arrange(municipio) %>% 
  unique() %>% pull(municipio)


### -------   Definir mapas de México y Nayarit   -------

mx_est <- readOGR(dsn = "./data/estados", layer = "states", encoding = "UTF-8")
mx_mun <- readOGR(dsn = "./data/municipios", layer = "municip", encoding = "UTF-8")

mx_map <- mx_est[!(mx_est$CVE_ENT %in% c('18')),]
nay_map <- mx_mun[mx_mun$CVE_ENT %in% c('18'),]



### -------   Deinir Iconos  -------

icons_ref <- awesomeIcons(
  icon = 'home',
  iconColor = 'white',
  library = 'ion',
  markerColor = "blue"
)


icons_ref_n <- awesomeIcons(
  icon = 'home',
  iconColor = 'white',
  library = 'ion',
  markerColor = "green"
)


icons_ref_a <- awesomeIcons(
  icon = 'home',
  iconColor = 'white',
  library = 'ion',
  markerColor = "red"
)


lngOk <- -99.12766
latOk <- 19.42847
lng2 <- -99.12766
lat2 <- 19.42847

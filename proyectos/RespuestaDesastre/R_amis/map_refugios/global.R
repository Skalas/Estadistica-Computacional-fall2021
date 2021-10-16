
library(dplyr)
library(shiny)
library(leaflet)
library(rgdal)
library(DT)
library(htmltools)
library(htmlwidgets)



refugios <- readRDS('./data/refugios_nayarit.Rds')

#source("./src/etl/etl.R"  , encoding = 'UTF-8')
source("./src/utils/utils.R"  , encoding = 'UTF-8')



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


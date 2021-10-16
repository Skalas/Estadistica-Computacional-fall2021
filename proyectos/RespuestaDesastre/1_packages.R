############################################################
#### LIBRERIAS #############################################
############################################################

library(openxlsx)
library(readxl)
library(stringr)
library(stringi)
library(dplyr)
library(ggmap)
library(geosphere)
library(leaflet)
library(dplyr)
library(purrr)
library(DT)
library(shiny)



install.lib<-load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib,require,character=TRUE)
# Se verifica si los paquetes están instalados----------------------------
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("sp")) install.packages("sp")

# Se cargan los paquetes----------------------------
library(tidyverse)
library(sp)

# Preproceso --------------------------------------------------------------

#Función que permite transformar a numérico la longitud y latitud

#Se utiliza try() para que no se detenga la función si hay un error, y así
# poder ver los renglones en los que no funciona

#Se utiliza Vectorize() para que pueda ser utilizada dentro de un mutate()

#Se utiliza char2dms del paquete sp para transformar a formato coord, y de ahí
## se transforma a numérico (dbl)

coord_2_dbl <- Vectorize(function(chr){
  
  val <- try(as.numeric(char2dms(chr, chd = "d", chm = "'",chs = '\"')))
  
  if(!is.numeric(val)) val <- NA

  val
})
# Limpia latitud y longitud ------------------------------------------------------

#Reemplaza caracteres incongruentes con el formato ddºmm'ss.ss"

dta <- readRDS('rds/data_merged.rds') %>% 
  filter(!is.na(long)) %>% #temporal, se imputaran
  mutate(across(c(lat, long), ~str_remove_all(.,'\"'))) %>%
  mutate(across(c(lat, long), ~str_replace_all(.,'ª|\\|','°'))) %>%  
  mutate(across(c(lat, long), ~str_replace_all(.,"°|º","d"))) %>% 
  mutate(across(c(lat, long), ~str_replace_all(.,"d'","d"))) %>% 
  mutate(across(c(lat, long), ~str_replace_all(.,"`","'"))) %>% 
  mutate(across(c(lat, long), ~str_replace_all(.,"\\-","."))) %>% 
  mutate(across(lat, ~paste0(.,'"N'))) %>% #Agrega N de North a la latitud
  mutate(across(long, ~paste0(.,'"W'))) %>%  # Agrega W de West a la longitud
  mutate(across(c(municipio, refugio, direccion, uso_inmueble), str_squish))

# Convertir a numérico ----------------------------------------------------


dta_try <- dta %>% 
  # select(num, lat, long) %>% 
  mutate(lat_dec = coord_2_dbl(lat),
         long_dec = coord_2_dbl(long))

#Ver en qué casos no funciona para intentar corregirlos
dta_try %>% 
  filter(is.na(lat_dec)|is.na(long_dec))

#Ver que todo esté dentro del rango esperado
dta_clean <- dta_try %>% 
  filter(!is.na(lat_dec)&!is.na(long_dec)) %>% 
  select(-lat, -long) %>% 
  rename(lat = lat_dec, long = long_dec) %>% 
  mutate(across(c(lat, long), as.double))

dta_clean %>% 
  summary()

dta_clean %>% 
  saveRDS('rds/data_clean.rds')

#dta_clean %>% 
#  distinct(municipio)
# pull(long)

#dta %>% 
#  filter(num == 213) %>% 
#  select(municipio, direccion)

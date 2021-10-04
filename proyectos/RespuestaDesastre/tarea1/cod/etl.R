# Instalar dependencias
install.packages('readxl')
install.packages('dplyr')
install.packages('tidyr')
install.packages('sp')

# Cargar librerías
library(readxl)
library(dplyr)
library(tidyr)
library(sp)

# Cargar datos
path <- '../dat/refugios_nayarit.xlsx'
df <- lapply(excel_sheets(path), read_xlsx, path=path, col_names=FALSE, skip=6) %>% bind_rows()

# Nombre de columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios','capacidad','lat','long',
              'alt','responsable','tel')

# Parsear `lat` y `long`
df <- df %>%
  filter(!(is.na(id) | is.na(lat) | is.na(long))) %>%  # Sin NAs en [id,lat,long]
  mutate(lat=gsub(' ','',lat), long=gsub(' ','',long)) %>%  # Quitar espacios (' ')
  separate(lat, into=paste0('lat', 1:4), sep='[^0-9]') %>% 
  separate(long, into=paste0('long', 1:4), sep='[^0-9]') %>% 
  mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'.',lat4,'s')) %>% 
  mutate(long=paste0(long1,'d',long2,'m',long3,'.',long4,'s')) %>% 
  select(-c(lat1,lat2,lat3,lat4,long1,long2,long3,long4)) # Quitar columnas temporales

# Convertir coordenadas de STR a DMS a NUM
df <- df %>%
  mutate(lat=char2dms(from=df$lat, chd='d', chm='m', chs='s') %>% as.numeric()) %>% 
  mutate(long=char2dms(from=df$long, chd='d', chm='m', chs='s') %>% as.numeric())
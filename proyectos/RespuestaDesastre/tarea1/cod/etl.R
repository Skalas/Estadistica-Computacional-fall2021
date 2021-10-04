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
df <- lapply(excel_sheets('./dat/refugios_nayarit.xlsx'), read_xlsx,
             path='./dat/refugios_nayarit.xlsx', col_names=FALSE, skip=6) %>% bind_rows()

# Nombre de columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios','capacidad','lat','long',
              'alt','responsable','tel')

# Partir en alfa (en vez de gsub)
t <- df %>%
  select(c(lat,long)) %>% 
  separate(lat, into=paste0('lat', 1:4), sep='[^0-9]', remove=FALSE) %>% 
  separate(long, into=paste0('long', 1:4), sep='[^0-9]', remove=FALSE) %>% 
  mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'s',lat4)) %>% 
  mutate(long=paste0(long1,'d',long2,'m',long3,'s',long4)) %>% 
  select(c(lat,long)) %>% 
  drop_na(c(lat, long))

# STR a DMS a NUM
coords <- c("22d29m56s06", "105d21m37s27")
char2dms(from=coords, chd='d', chm='m', chs='s') %>% as.numeric()


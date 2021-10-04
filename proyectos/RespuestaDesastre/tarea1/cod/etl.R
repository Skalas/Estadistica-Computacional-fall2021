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

# Quitar NAs sobre `id`, `lat` y `long`
df <- df %>% filter(!(is.na(id) | is.na(lat) | is.na(long)))
# Quitar espacios en `lat` y `long`
df <- df %>% mutate(lat=gsub(' ','',lat), long=gsub(' ','',long))

# Partir en caracteres no-numéricos (en vez de gsub)
t <- df %>%
  select(c(id,lat,long)) %>% 
  separate(lat, into=paste0('lat', 1:4), sep='[^0-9]', remove=FALSE) %>% 
  separate(long, into=paste0('long', 1:4), sep='[^0-9]', remove=FALSE) %>% 
  mutate(lat=paste0(lat1,'d',lat2,'m',lat3,'.',lat4,'s')) %>% 
  mutate(long=paste0(long1,'d',long2,'m',long3,'.',long4,'s'))

char2dms(from=c(t$lat, t$long), chd='d', chm='m', chs='s') %>% as.numeric()

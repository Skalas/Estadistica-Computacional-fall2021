# Instalar dependencias
install.packages('readxl')
install.packages('dplyr')

# Cargar librerías
library(readxl)
library(dplyr)

# Cargar datos
df <- lapply(excel_sheets('./dat/refugios_nayarit.xlsx'), read_xlsx,
             path='./dat/refugios_nayarit.xlsx', col_names=FALSE, skip=6) %>% bind_rows()
# Nombre de columnas
names(df) <-c('id','refugio','municipio','direccion','tipo','servicios','capacidad','lat','long',
              'alt','responsable','tel')

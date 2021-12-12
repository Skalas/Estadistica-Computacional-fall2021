# Se verifica si los paquetes están instalados----------------------------

if(!require("tidyverse")) install.packages("tidyverse")
if(!require("openxlsx")) install.packages("openxlsx")

# Se cargan los paquetes----------------------------
library(tidyverse)
library(openxlsx)


# Preproceso --------------------------------------------------------------

#Crea vector de encabezados
headers <- c("num", "refugio", "municipio", "direccion", "uso_inmueble","servicios",
             "capacidad", "lat","long","altitud","responsable","tel")

#Crea funci?n que lee cada hoja y asigna el nombre correcto del encabezado
carga_data <- function(sheetname = "1-20"){

dta <- read.xlsx('data/refugios_nayarit.xlsx', startRow = 6, sheet = sheetname) %>% 
  as_tibble() %>% 
  set_names(headers) %>% 
  filter(!is.na(num)) #quita renglon de totales

dta
}



# Lee y junta datos -------------------------------------------------------

#Cargar workbook
wb <- loadWorkbook('data/refugios_nayarit.xlsx')
sheets <- sheets(wb)

#Correr función para cada una de las hojas
dta_merged <- sheets %>% 
  map_df(carga_data)

#Carga imputaciones -------------------------------------------------------
imputaciones <- read.xlsx('data/imputaciones_reservas.xlsx', startRow = 6) %>% 
  as_tibble() %>% 
  set_names(headers)

#Reemplaza imputaciones -------------------------------------------------------
aux1  <- as.integer(count(imputaciones))
aux2  <- as.integer(count(dta_merged))

for ( i in 1:aux1 ){
  for (n in 1:aux2){
  if (dta_merged$num[n] == imputaciones$num[i]) {
    a <- which(dta_merged$num == imputaciones$num[i])
    dta_merged[a,] <- imputaciones[i,]
  }
  }
}  



#Almacenar en RDS para usarse en otro script
dta_merged %>% 
  saveRDS('rds/data_merged.rds')



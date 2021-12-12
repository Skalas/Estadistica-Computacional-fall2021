library(readxl)
library(dplyr)
library(tidyverse)
library(sp)

tamanios <- c("Hasta 50 personas", "Entre 50 y 100 personas", 
              "Más de 100 personas")

etl <- function(table="data/refugios_nayarit.xlsx"){
  data_sheets <- excel_sheets(table)
  all_tables <- lapply(data_sheets, function(x) read_excel(path = table, sheet = x,  skip=2))
  df <- do.call("rbind", all_tables)
  df <- 
    df %>%
    drop_na(No.) %>% 
    rename(LATITUD_ = 8, LONGITUD_ = 9, ALTITUD = 10,
           "CAPACIDAD.DE.PERSONAS"="CAPACIDAD DE PERSONAS" ) %>%
    filter(grepl("(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+",LATITUD_)
           & grepl("(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+",LONGITUD_))  %>%
    mutate(LATITUD_ = sub("(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+", "\\1°\\2'\\3.\\4\"N", LATITUD_),
           LONGITUD_ = sub("(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+(\\d+)\\D+", "\\1°\\2'\\3.\\4\"W", LONGITUD_),
           LATITUD = paste(if_else((abs(as.numeric(str_extract(LATITUD_, regex("(\\d+)")))) > 90) & 
             (abs(as.numeric(str_extract(LONGITUD_, regex("(\\d+)")))) <= 90), LONGITUD_, LATITUD_), "\"N",  sep = ""),
           LONGITUD = paste(if_else((abs(as.numeric(str_extract(LATITUD_, regex("(\\d+)")))) > 90) & 
                     (abs(as.numeric(str_extract(LONGITUD_, regex("(\\d+)")))) <= 90), LATITUD_,LONGITUD_), "\"W",  sep = "")
           )%>%
    filter((!abs(as.numeric(str_extract(LATITUD, regex("(\\d+)")))) > 90) & 
           (!abs(as.numeric(str_extract(LONGITUD, regex("(\\d+)")))) > 180)) %>%
    mutate(LATITUD = as.numeric(char2dms(LATITUD, chd = "°", chm = "'", chs = '"')),
           LONGITUD = as.numeric(char2dms(LONGITUD, chd = "°", chm = "'", chs = '"')),
           tamanio_refugio =
             case_when(
               CAPACIDAD.DE.PERSONAS <= 50 ~ "Hasta 50 personas",
               CAPACIDAD.DE.PERSONAS > 50 & CAPACIDAD.DE.PERSONAS <= 100 ~ "Entre 50 y 100 personas",
               CAPACIDAD.DE.PERSONAS > 100 ~ "Más de 100 personas"),
           factor(tamanio_refugio,
                  levels = tamanios)
           ) %>%
    select(-LATITUD_, -LONGITUD_)
  
  return(df)
}
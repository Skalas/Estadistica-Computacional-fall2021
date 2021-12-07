if(!require("tidyverse")) install.packages("tidyverse")
if(!require("geosphere")) install.packages("geosphere")

library(tidyverse)
library(geosphere)

# Cargar en background ----------------------------------------------------

dta <- readRDS('rds/data_clean.rds')

mtx_coord <- dta %>% 
  select(long, lat) %>% 
  as.matrix()

# calcula_dist ------------------------------------------------------------

calcula_dist <- function(long,lat,nrows = 6){
  
  input_point <- c(long, lat)
  
  dta_dist <- dta %>% 
    mutate(distancia = distCosine(input_point, mtx_coord)) %>% 
    arrange(distancia) %>% 
    select(refugio,municipio, direccion, tel, lat, long, distancia) %>%  #por definir info a mostrar
    distinct(lat, long, .keep_all = TRUE) %>% 
    head(nrows) #por definir num de renglones a mostrar
  
  dta_dist
  
}



# install.packages("leaflet")
if (!require("devtools")) {
  install.packages("devtools")
}
# devtools::install_github("diegovalle/mxmaps")
# install.packages("geosphere")
library(geosphere)

# install.packages("tidymodels")
library(tidymodels)

library(leaflet)
library(magrittr)
library(sp)
# library(mxmaps)
library(stringr)
library(readxl)

### Algunas usadas para los mapas
# install.packages("rgdal")
# install.packages("geojsonio")
# install.packages("spdplyr")
# install.packages("rmapshaper")
# install.packages("jsonlite")
# install.packages("highcharter")
# 
# library(rgdal)
# library(geojsonio)
# library(spdplyr)
# library(rmapshaper)
# library(jsonlite)
# library(highcharter)

### Mejoras:
# 1. Estamos quitando todos los NA. Tal vez seria mejor solo quitar los
# renglones con NA en Nombre, Latitud y/o Longitud
# 3. Corregir el renglon que tiene volteada la Latitud y Longitud (434)
# 4. Hay algunas coordenadas que se repiten (p.ej. 414, 415 y 416). Entonces,
# hay que determinar que hacer. Al momento, se estan sobrescribiendo, pero una
# idea podria ser mostrar todos los valores en el popup.

municipios <- list("ACAPONETA"="ACAPONETA","AHUACATLAN"="AHUACATLAN",
                   "AMATLAN DE CAÑAS"="AMATLAN DE CAÑAS","COMPOSTELA" ="COMPOSTELA",
                   "COMPOSTELA"="COMPOSTELA","RUIZ"="RUIZ",
                   "SAN BLAS"="SAN BLAS", "SAN PEDRO LAGUNILLAS"="SAN PEDRO LAGUNILLAS",
                   "SAN PEDRO LAGUNILLAS"="SAN PEDRO LAGUNILLAS", 
                   "SANTA MARIA DEL ORO"="SANTA MARIA DEL ORO",
                   "SANTIAGO IXCUINTLA"="SANTIAGO IXCUINTLA",
                   "TECUALA"="TECUALA","TEPIC"="TEPIC","TUXPAN"="TUXPAN",
                   "LA YESCA"="LA YESCA","XALISCO"="XALISCO","HUAJICORI"="HUAJICORI",
                   "IXTLAN DEL RIO"="IXTLAN DEL RIO","JALA"="JALA","ROSAMORADA"="ROSAMORADA",
                   "BAHIA DE BANDERAS"="BAHIA DE BANDERAS")


filepath <-"data/refugios_nayarit.xlsx"
n_hojas <- length(excel_sheets(filepath))
n_closer <- 5

datos <- read_excel(filepath, skip = 6, col_names = c("No.", "Refugio", "Municipio", "Direccion", "Uso del Inmueble", "Servicios", "Capacidad de Personas", "Latitud", "Longitud", "Altitud", "Responsable", "Telefono"), na = "na")
datos <- datos[-dim(datos)[1],]

for(i in 2:n_hojas){
  pagina_k <- read_excel(filepath, skip = 6, col_names = c("No.", "Refugio", "Municipio", "Direccion", "Uso del Inmueble", "Servicios", "Capacidad de Personas", "Latitud", "Longitud", "Altitud", "Responsable", "Telefono"), sheet = i)
  pagina_k <- pagina_k[-dim(pagina_k)[1],]
  datos <- rbind(datos,pagina_k)
}

### Quitamos los NA
datos <- datos |> drop_na()

### Agregamos los primeros dos valores si es que los 

# convert_coordinates <- function(x){
#   ### Segun Wikipedia: D_dec = D + M/60 + S/3600
#   
#   # Obtenemos las 3 componentes (degrees, minutes, and seconds) haciendo splits
#   coords <- x |>
#             strsplit(split = "°") |> 
#             unlist() |> 
#             strsplit(split = "º") |> 
#             unlist() |> 
#             strsplit(split = "ª") |> 
#             unlist() |> 
#             # strsplit(split = "|") |> 
#             # unlist() |> 
#             strsplit(split = "'") |> 
#             unlist() |> 
#             strsplit(split = "\"") |> 
#             unlist() |>
#             as.numeric()
#             
#   D <- coords[1]
#   M <- coords[2]
#   S <- coords[3]
#   
#   D + M/60 + S/3600
# }

convert_coordinates <- function(x){
  ### Segun Wikipedia: D_dec = D + M/60 + S/3600
  
  # Obtenemos las 3 componentes (degrees, minutes, and seconds) haciendo regex
  matches <- regmatches(x, gregexpr("[[:digit:]]+", x))
  matches <- as.numeric(unlist(matches))
  
  D <- matches[1]
  M <- matches[2]
  S <- matches[3] +  matches[4]/100
  
  D + M/60 + S/3600
}

### Aqui podemos ver aquellos valores problematicos. En general, se
### puede robustecer la funcion convert_coordinates para que los cache.

aux <- map_dbl(datos$Latitud, convert_coordinates)
problematic_Lat <- datos$No.[aux |> is.na()]
datos |> filter(No.  %in%  problematic_Lat) |> pull(Latitud)

aux <- map_dbl(datos$Longitud, convert_coordinates)
problematic_Lon <- datos$No.[aux |> is.na()]
datos |> filter(No.  %in%  problematic_Lon) |> pull(Longitud)

### Trabajamos con los datos asi por el momento, quitando NA

corregidos <- datos |>
                mutate(Latitud_Dec =  map_dbl(Latitud, convert_coordinates),
                       Longitud_Dec =  map_dbl(Longitud, convert_coordinates)) |>
                select(-c("Latitud", "Longitud")) |>
                drop_na()

### Notamos que existe un valor para el cual la Latitud y Longitud estan
### volteadas (puede ser que haya mas para los NA que quitamos).
### Dejamos esta correccion para despues, por el momento lo quitamos

corregidos |>
  filter(Latitud_Dec > 30) |>
  select(c("No.", "Latitud_Dec", "Longitud_Dec"))

corregidos <- corregidos |>
                filter(Latitud_Dec < 30)

### La Longitud debe estar negativo (si no los grafica del otro lado del mundo)
corregidos <- corregidos |>
               mutate(Longitud_Dec = ifelse(Longitud_Dec > 0, -1*Longitud_Dec, Longitud_Dec))


#Estas cuatro lineas son un ejemplo de lo que se haria si se ingresan en coordenadas
#De esta forma, podemos forzar en el input a que se agreguen los caracteres º, ' y ".
ubicacion_actual <- c(corregidos$Latitud[100], datos$Longitud[100])
ubicacion_actual <- ubicacion_actual |> map_dbl(convert_coordinates)
ubicacion_actual <- c("21º56'52.71", "105º08'40.55")
ubicacion_actual <- ubicacion_actual |> map_dbl(convert_coordinates)

###### 

#Esto seria si ya se le pasa el vector en coordenadas decimales
ubicacion_actual <- c(21, -105)

#Para cualquier caso, lo agregamos a un df para pasarlo al mapa
ubicacion_actual_df <- tibble(id = "Ubicacion actual",
                              lat = ubicacion_actual[1],
                              lng = ubicacion_actual[2])


### Funcion para calcular distancias entre coordenadas
distancia <- function(x1, x2, y1, y2){
  # sqrt((x1 - x2)^2 + (y1 - y2)^2)
  distHaversine(c(y1,x1), c(y2,x2))
}

### Calculamos todas las distancias. Primero arreglamos los datos para luego
### pasarlo al pmap_dbl
aux_dist <- corregidos |> 
              mutate(x_actual = ubicacion_actual[1], y_actual = ubicacion_actual[2]) |>
              select(c("Latitud_Dec", "x_actual" , "Longitud_Dec", "y_actual")) |>
              rename(x1 = Latitud_Dec, x2 = x_actual, y1 = Longitud_Dec, y2 = y_actual)

corregidos$dist <- pmap_dbl(list(aux_dist$x1, aux_dist$x2, aux_dist$y1, aux_dist$y2), distancia)


nayarit_refugios <- corregidos
municipios_unicos <- nayarit_refugios$Municipio |> unique()



obten_mas_cercanos <- function(lat_D, lat_M, lat_S, lon_D, lon_M, lon_S){
  
  latitud_actual <- paste(lat_D, "º", lat_M, "'", lat_S, sep = "" )
  longitud_actual <- paste(lon_D, "º", lon_M, "'", lon_S,sep = "" )
  ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
  
  
  aux_dist <- nayarit_refugios |> 
    mutate(x_actual = ubicacion_actual[1], y_actual = -1*ubicacion_actual[2]) |>
    select(c("Latitud_Dec", "x_actual" , "Longitud_Dec", "y_actual")) |>
    rename(x1 = Latitud_Dec, x2 = x_actual, y1 = Longitud_Dec, y2 = y_actual)
  
  nayarit_refugios$dist <- pmap_dbl(list(aux_dist$x1, aux_dist$x2, aux_dist$y1, aux_dist$y2), distancia)
  
  #Tomamos los n_closer mas cercanos
  mas_cercanos <- nayarit_refugios |>
    arrange(dist) |>
    head(n_closer)
  
  mas_cercanos
}  

obten_ubicacion_actual_df <- function(lat_D, lat_M, lat_S, lon_D, lon_M, lon_S){
  
  latitud_actual <- paste(lat_D, "º", lat_M, "'", lat_S, sep = "" )
  longitud_actual <- paste(lon_D, "º", lon_M, "'", lon_S,sep = "" )
  ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
  
  #Para cualquier caso, lo agregamos a un df para pasarlo al mapa
  ubicacion_actual_df <- tibble(id = "Ubicacion actual",
                                lat = ubicacion_actual[1],
                                lng = -1*ubicacion_actual[2])
  
  ubicacion_actual_df
}

obten_municipios <- function(municipio){
  ### Por municipios (en la implementacion, dar a elegir de una lista)
  municipio_actual <- municipio
  por_municipio <- nayarit_refugios |>
    filter(Municipio == municipio_actual)
}


# #Tomamos los n_closer mas cercanos
# mas_cercanos <- nayarit_refugios |>
#                   arrange(dist) |>
#                   head(n_closer)
# 
# 
# ### Por municipios (en la implementacion, dar a elegir de una lista)
# municipio_actual <- "ROSAMORADA"
# por_municipio <- nayarit_refugios |>
#                   filter(Municipio == municipio_actual)
# 
# ########## Algunas pruebas para colorear por municipio
# 
# # nayarit_map <- rgdal::readOGR("data/estado18.json")
# # 
# # nayarit_map <- nayarit_map |>
# #                 mutate(state_code=as.factor(as.numeric(as.character(state_code))),
# #                        mun_code=as.factor(as.numeric(as.character(mun_code))))
# # 
# # nay_new <- spTransform(nayarit_map, CRS("+proj=longlat +init=epsg:4326"))
# # 
# # leaflet() %>%
# #   addProviderTiles("CartoDB.Positron", options= providerTileOptions(opacity = 0.99)) %>%
# #   addPolygons(data = nay_new,
# #               stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5
# #   )
# 
# ##########
# 
# # leaflet() |>
# #   addTiles() |>
# #   # addPolygons(data = nayarit_map_2, 
# #   #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
# #   #             # fillColor = ~pal(log10(pop)),
# #   #             label = ~mun_name) |>
# #   addMarkers(data = corregidos, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
# #              popup = ~paste(Refugio, Telefono, sep="\n")) |>
# #   addAwesomeMarkers(data = ubicacion_actual_df, lat = ~lat, lng = ~lng, popup = ~id, 
# #                     icon  = awesomeIcons(iconColor = 'black',markerColor = "orange"))
# # 
# # leaflet() |>
# #   addTiles() |>
# #   # addPolygons(data = nayarit_map_2, 
# #   #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
# #   #             # fillColor = ~pal(log10(pop)),
# #   #             label = ~mun_name) |>
# #   addMarkers(data = mas_cercanos, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
# #              popup = ~paste(Refugio, Telefono, sep="\n")) |>
# #   addAwesomeMarkers(data = ubicacion_actual_df, lat = ~lat, lng = ~lng, popup = ~id, 
# #                     icon  = awesomeIcons(iconColor = 'black',markerColor = "orange"))
# # 
# # leaflet() |>
# #   addTiles() |>
# #   # addPolygons(data = nayarit_map_2, 
# #   #             stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
# #   #             # fillColor = ~pal(log10(pop)),
# #   #             label = ~mun_name) |>
# #   addMarkers(data = por_municipio, lat = ~Latitud_Dec, lng = ~Longitud_Dec,
# #              popup = ~paste(Refugio, Telefono, sep="\n"))
# # 
# 
# 
# #### Referencias
# # http://rstudio-pubs-static.s3.amazonaws.com/327743_a932d7ebdce548dfa7c7ca2b3ff6e038.html
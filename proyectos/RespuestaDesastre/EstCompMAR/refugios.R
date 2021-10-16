if (!require("devtools")) {
  install.packages("devtools")
}
library(geosphere)
library(tidymodels)

library(leaflet)
library(magrittr)
library(sp)
library(stringr)
library(readxl)


###Creamos filepath para leer los datos
filepath <-"data/refugios_nayarit.xlsx"
n_hojas <- length(excel_sheets(filepath))
n_closer <- 5

###Leemos los datos
datos <- read_excel(filepath, skip = 6, col_names = c("No.", "Refugio", "Municipio", "Direccion", "Uso del Inmueble", "Servicios", "Capacidad de Personas", "Latitud", "Longitud", "Altitud", "Responsable", "Telefono"), na = "na")
datos <- datos[-dim(datos)[1],]

###Leemos las hojas del excel
for(i in 2:n_hojas){
  pagina_k <- read_excel(filepath, skip = 6, col_names = c("No.", "Refugio", "Municipio", "Direccion", "Uso del Inmueble", "Servicios", "Capacidad de Personas", "Latitud", "Longitud", "Altitud", "Responsable", "Telefono"), sheet = i)
  pagina_k <- pagina_k[-dim(pagina_k)[1],]
  datos <- rbind(datos,pagina_k)
}

### Quitamos los NA, dejamos en municipio y refugio por si hay datos nuevos con valores NA ahí
datos <- datos[!is.na(datos$Latitud), ]
datos <- datos[!is.na(datos$Longitud), ]
datos <- datos[!is.na(datos$Refugio), ]
datos <- datos[!is.na(datos$Municipio), ]


###Creamos lista de municipios del Estado de Nayarit
municipios <- datos |> 
                pull(Municipio) |>
                unique() |>
                sort()
              

###Convertimos coordenadas
convert_coordinates <- function(x){
  ### Segun Wikipedia: D_dec = D + M/60 + S/3600
  # Obtenemos las 3 componentes (degrees, minutes, and seconds) haciendo regex
  matches <- regmatches(x, gregexpr("[[:digit:]]+", x))
  matches <- as.numeric(unlist(matches))
  D <- matches[1]
  M <- matches[2]
  if(is.na(matches[4]) == T) {
    S <- matches[3] 
  } else {
    S <- matches[3] +  matches[4]/100
  }
  D + M/60 + S/3600
}

inverse_coordinates <- function(x){
  D <- trunc(x)
  M <- trunc(60*(x - D))
  S <- 3600*abs(x - D)-60*M
  
  c(D, M, S)
}

### Convertimos las coordenadas
corregidos <- datos |>
                mutate(Latitud_Dec =  map_dbl(Latitud, convert_coordinates),
                       Longitud_Dec =  map_dbl(Longitud, convert_coordinates)) |>
                select(-c("Latitud", "Longitud"))

### Notamos que existe un valor para el cual la Latitud y Longitud estan
### volteadas (puede ser que haya mas para los NA que quitamos).
### Dejamos esta correccion para despues, por el momento lo quitamos

aux_vals <- corregidos |>
  filter(Latitud_Dec > 30) |>
  mutate(dummy = Longitud_Dec, Longitud_Dec = Latitud_Dec, Latitud_Dec = dummy) |> 
  select(-dummy)

corregidos <- rbind(
corregidos |> 
  filter(No. %in% aux_vals$No. == FALSE), aux_vals) |> 
  arrange(by = No.) |>
  filter(Latitud_Dec >= 20) |> 
  filter(Latitud_Dec <= 23) |> 
  filter( Longitud_Dec >= 103) |> 
  filter(Longitud_Dec <= 106)

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

###Pasamos los corregidos
nayarit_refugios <- corregidos
municipios_unicos <- nayarit_refugios$Municipio |> unique()

###Obtenemos interactivos
obten_interactivos <- function(lat,lon){
  ubicacion_actual <- c(lat, lon)
  
  
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

obten_interactivos_df <- function(lat,lon){
  ubicacion_actual <- c(lat, lon)
  #Para cualquier caso, lo agregamos a un df para pasarlo al mapa
  ubicacion_actual_df <- tibble(id = "Ubicacion actual",
                                lat = ubicacion_actual[1],
                                lng = -1*ubicacion_actual[2])
  ubicacion_actual_df
}

#Obtenemos los refugios más cercanos
obten_mas_cercanos <- function(lat_D, lat_M, lat_S, lon_D, lon_M, lon_S){
  latitud_actual <- paste(lat_D, "º", lat_M, "'", lat_S, sep = "" )
  longitud_actual <- paste(lon_D, "º", lon_M, "'", lon_S,sep = "" )
  ubicacion_actual <- c(latitud_actual, longitud_actual) |> map_dbl(convert_coordinates)
  
#Normalizamos   
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

#Obtenemos ubicación actual a partir de coordenadas
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

### En caso que haya ubicaciones repetidas, los popups, muestran los datos de los refugios
descripciones_popups <- function(datos){
  unique_coords <- datos |>
                    mutate(lat_lon = paste(Latitud_Dec, Longitud_Dec)) |>
                    group_by(lat_lon) |>
                    summarise(n = n()) |>
                    pull(lat_lon)
  new_aux <- datos |> mutate(lat_lon = "", popup = "") |> head(1)
  for (coord in unique_coords){
    
    popup <- paste(datos |>
                      mutate(lat_lon = paste(Latitud_Dec, Longitud_Dec),
                             popup = paste(Refugio, Telefono)) |>
                      filter(lat_lon == coord) |>
                      pull(popup), collapse = "\n"
                  )
    new_aux <- rbind(new_aux, datos |>
                                mutate(lat_lon = paste(Latitud_Dec, Longitud_Dec)) |>
                                filter(lat_lon == coord) |>
                                head(1) |>
                                mutate(popup = popup))
        }
  new_aux[-1,]
}


### Funcion auxiliar para los temas de shiny
themeSelector <- function() {
  div(
    div(
      selectInput("shinytheme-selector", "Choose a theme",
                  c("default", shinythemes:::allThemes()),
                  selectize = FALSE
      )
    ),
    tags$script(
      "$('#shinytheme-selector')
        .on('change', function(el) {
        var allThemes = $(this).find('option').map(function() {
        if ($(this).val() === 'default')
        return 'bootstrap';
        else
        return $(this).val();
        });
        // Find the current theme
        var curTheme = el.target.value;
        if (curTheme === 'default') {
        curTheme = 'bootstrap';
        curThemePath = 'shared/bootstrap/css/bootstrap.min.css';
        } else {
        curThemePath = 'shinythemes/css/' + curTheme + '.min.css';
        }
        // Find the <link> element with that has the bootstrap.css
        var $link = $('link').filter(function() {
        var theme = $(this).attr('href');
        theme = theme.replace(/^.*\\//, '').replace(/(\\.min)?\\.css$/, '');
        return $.inArray(theme, allThemes) !== -1;
        });
        // Set it to the correct path
        $link.attr('href', curThemePath);
        });"
    )
  )
}

  
# #### Referencias
# # http://rstudio-pubs-static.s3.amazonaws.com/327743_a932d7ebdce548dfa7c7ca2b3ff6e038.html
library(dplyr)
library(rgdal)
library(magrittr)
library(leaflet)
library(readxl)
library(purrr)
library(tidyr)
library(geosphere)

loadingLogo <- function(href, src, loadingsrc, height = NULL, width = NULL, alt = NULL) {
 tagList(
  tags$head(
   tags$script(
    "setInterval(function(){
      if ($('html').attr('class')=='shiny-busy') {
      $('div.busy').show();
      $('div.notbusy').hide();
      } else {
      $('div.busy').hide();
      $('div.notbusy').show();
      }
    },100)")
  ),
  tags$a(href=href,
         div(class = "busy",  
             img(src=loadingsrc,height = height, width = width, alt = alt)),
         div(class = 'notbusy',
             img(src = src, height = height, width = width, alt = alt))
  )
 )
}

distance_compute <- function(data, lat_input, lon_input){ 
  # This function returns the distance of a vector vs the inputs of nayarit in kilometers
  
  data <- data %>% rowwise() %>% 
    mutate(distance = as.vector(
      round(distm(c(lng, lat), c(lon_input,lat_input), fun=distGeo)/1000, 3)
      )
    )
  
  return(data) 
}

shp <- readOGR("data/municipal.shp") %>% 
  spTransform(CRS("+proj=longlat +datum=WGS84"))

path <- list.files("data/", pattern = ".xlsx", full.names = T)

data <- path %>% 
  excel_sheets() %>% 
  map(function(X) readxl::read_excel(path = path, sheet = X, skip = 5, trim_ws = T)) %>% 
  bind_rows()

names(data) <- c("no", "refugio", "municipio", "direccion", "uso_inmueble",
                 "servicios", "capacidad", "lat", "lng", "alt", "responsable", 
                 "telefono")

set.seed(12345)
data %<>%  
  mutate(
    uso_cat = case_when(
      uso_inmueble == "EDUCACION" ~ "Educación",
      uso_inmueble == "EJIDAL" ~ "Ejidal",
      uso_inmueble == "GOBIERNO MUNICIPAL" ~ "Gobierno Municipal",
      T ~ "Otros"
    )
  ) %>% 
  separate(lat, c("d","m","s_int","s_dec", "basura"), sep = "([°º'\\,ª.;\"])") %>% 
  separate(lng, c("d_lg","m_lg","s_int_lg","s_dec_lg", "basura_lg"), sep = "([°º'\\,ª.;\"])") %>% 
  mutate(
    coor1 = as.numeric(d) + as.numeric(m)/60 + as.numeric(s_int)/3600 + as.numeric(s_dec)/360000,
    coor2 = (as.numeric(d_lg) + as.numeric(m_lg)/60 + as.numeric(s_int_lg)/3600 + as.numeric(s_dec_lg)/360000)) %>% 
  filter(!is.na(no)) %>% 
  rowwise() %>% 
  mutate(
    disponibilidad = sample(capacidad, size = 1),
    lat = pmin( coor1,coor2), 
    lng = -pmax(coor1, coor2)) %>% 
  relocate("alt", .after = last_col()) %>% 
  select(-c(coor1, coor2, d,m,s_int,s_dec, basura, d_lg, m_lg, s_int_lg, s_dec_lg,basura_lg))

#uso_inmueble <- c("EDUCACION", "EJIDAL", "GOBIERNO MUNICIPAL", "OTROS")
pal <- colorFactor(
  palette = c("#9f51dc","#8edc51","#dc5951","#51d3dc"), 
  domain = unique(data$uso_cat)
  )

labels <- sprintf(
  "<strong> Refugio: </strong> <br/> %s <br/>
   <strong> Servicios: </strong> <br/> %s <br/>
   <strong> Capacidad: </strong> <br/> %s personas <br/>
   <strong> Disponibilidad: </strong> <br/> %g personas <br/>
   <strong> Responsable: </strong> <br/> %s <br/>
   <strong> Teléfono: </strong> <br/> %s <br/>",
  tolower(data$refugio), 
  tolower(data$servicios), 
  tolower(data$capacidad), 
  data$disponibilidad,
  tolower(data$responsable), 
  tolower(data$telefono)) %>% 
  map(htmltools::HTML)







##### Cálculo de distancias #####

# lat_input <- 21.736867
# lon_input <- -104.756833

# distance_compute(data, lat_input , lon_input) %>% glimpse()



##### JOINS GEOESPACIAL #####

library(spatialEco)

shape_loc <- readOGR("data/loc_urb.shp") %>% spTransform(CRS("+proj=longlat +datum=WGS84"))

shape_loc@data <- shape_loc@data %>% 
  select (CVEGEO,NOM_ENT,NOM_MUN,NOMGEO)

data1 <-  data %>% filter( !is.na(lat))
coordinates(data1) <- ~ lng + lat
proj4string(data1) <- proj4string(shape_loc)
data_spacialjoined <- data1 %>% point.in.poly(shape_loc)
data_spacialjoined@data %>% head()






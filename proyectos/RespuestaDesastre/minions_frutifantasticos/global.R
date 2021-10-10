library(dplyr)
library(rgdal)
library(magrittr)
library(leaflet)
library(readxl)
library(purrr)
library(tidyr)

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

data %<>%  
  mutate(
    uso_cat = case_when(
      uso_inmueble == "EDUCACION" ~ "EDUCACION",
      uso_inmueble == "EJIDAL" ~ "EJIDAL",
      uso_inmueble == "GOBIERNO MUNICIPAL" ~ "GOBIERNO MUNICIPAL",
      T ~ "OTROS"
    )
  ) %>% 
  separate(lat, c("d","m","s_int","s_dec", "basura"), sep = "([°º'\\,ª.;\"])") %>% 
  separate(lng, c("d_lg","m_lg","s_int_lg","s_dec_lg", "basura_lg"), sep = "([°º'\\,ª.;\"])") %>% 
  mutate(
    coor1 = as.numeric(d) + as.numeric(m)/60 + as.numeric(s_int)/3600 + as.numeric(s_dec)/360000,
    coor2 = (as.numeric(d_lg) + as.numeric(m_lg)/60 + as.numeric(s_int_lg)/3600 + as.numeric(s_dec_lg)/360000)) %>% 
  mutate(lat = pmin( coor1,coor2), lng = -pmax(coor1, coor2)) %>% 
  select(-c(coor1, coor2, d,m,s_int,s_dec, basura, d_lg, m_lg, s_int_lg, s_dec_lg,basura_lg))

#uso_inmueble <- c("EDUCACION", "EJIDAL", "GOBIERNO MUNICIPAL", "OTROS")
pal <- colorFactor(
  palette = c("#9f51dc","#8edc51","#dc5951","#51d3dc"), 
  domain = unique(data$uso_cat)
  )


labels <- sprintf(
  "<strong>%s</strong><br/>
    %g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

labels <- sprintf(
  "<strong>Refugio:</strong><br/>%s<br/>
   <strong>Servicios:</strong><br/>%s<br/>
   <strong>Capacidad:</strong><br/>%s<br/>
   <strong>Responsable:</strong><br/>%s<br/>
   <strong>Teléfono:</strong><br/>%s<br/>",
  data$refugio, data$servicios, data$capacidad, 
  data$responsable, data$telefono
) %>% lapply(htmltools::HTML)







##### Cálculo de distancias #####

# lat_input <- 21.736867
# lon_input <- -104.756833

library(geosphere)
distance_compute <- function(data, lat_input, lon_input){ 
  
  # This function returns the distance of a vector vs the inputs of nayarit in meters

  data <- data %>% rowwise() %>% 
    mutate(distance = as.vector(distm(c(lng, lat), c(lon_input,lat_input), fun=distGeo)))
  
  return(data) }


# distance_compute (data, lat_input , lon_input)



##### JOINS GEOESPACIAL #####



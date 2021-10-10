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

path <- "data/refugios_nayarit.xlsx" 

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
    lat = as.numeric(d) + as.numeric(m)/60 + as.numeric(s_int)/3600 + as.numeric(s_dec)/360000,
    lng = -(as.numeric(d_lg) + as.numeric(m_lg)/60 + as.numeric(s_int_lg)/3600 + as.numeric(s_dec_lg)/360000)) %>% 
  select(-c(d,m,s_int,s_dec, basura, d_lg, m_lg, s_int_lg, s_dec_lg,basura_lg)) %>% 
  filter(!is.na(no)) %>% 
  relocate("alt", .after = last_col()) %>% 
  rowwise() %>% 
  mutate(disponibilidad = sample(capacidad, size = 1))


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















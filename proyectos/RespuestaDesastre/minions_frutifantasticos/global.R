library(dplyr)
library(rgdal)
library(magrittr)
library(leaflet)

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

data <- readRDS("data/refugios.rds") %>% .[-(1:2),]
data %<>%  
  rename_with(~ tolower(gsub(" ", "_", .x, fixed = TRUE))) %>% 
  rename(lng = longitud, lat = latitud) %>% 
  mutate(
    lng = sample(seq(shp@bbox[1,1]+0.5, shp@bbox[1,2], length.out = 10000), 435),
    lat = sample(seq(shp@bbox[2,1], shp@bbox[2,2], length.out = 10000), 435),
    uso_cat = case_when(
      uso_del_inmueble == "EDUCACION" ~ "EDUCACION",
      uso_del_inmueble == "EJIDAL" ~ "EJIDAL",
      uso_del_inmueble == "GOBIERNO MUNICIPAL" ~ "GOBIERNO MUNICIPAL",
      T ~ "OTROS"
    )
    )

#uso_inmueble <- c("EDUCACION", "EJIDAL", "GOBIERNO MUNICIPAL", "OTROS")
pal <- colorFactor(
  palette = c("#9f51dc","#8edc51","#dc5951","#51d3dc"), 
  domain = unique(data$uso_cat)
  )


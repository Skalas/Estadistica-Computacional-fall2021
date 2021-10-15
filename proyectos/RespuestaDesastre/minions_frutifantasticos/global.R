library(dplyr)
library(rgdal)
library(magrittr)
library(leaflet)
library(readxl)
library(purrr)
library(tidyr)
library(geosphere)
library(spatialEco)

#### Funciones ####
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
    ) %>% 
    ungroup()
  
  return(data) 
}

icons <- function(color){
  awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = color
  )
}

my_icon = makeAwesomeIcon(
  icon = 'home', 
  markerColor = 'red', 
  iconColor = 'white'
)




dis_graph <- function(data) {
  
  grafica <- data %>% 
    head(10) %>%
    select(refugio, capacidad, disponibilidad) %>% 
    mutate(ocupacion = capacidad - disponibilidad) %>% 
    select(-capacidad) %>% 
    pivot_longer(!refugio, names_to = "Capacidad" ) %>% 
    ggplot(aes(x = reorder(refugio, -desc(value)), y= value, z = Capacidad, fill= Capacidad )) +
    geom_bar(position="stack", stat="identity", col="black")  +
    scale_fill_manual(values= (c("forestgreen", "darkgrey"))) +
    ggtitle("Disponibilidad y ocupación por refugio") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    xlab("") +
    ylab("")+
    coord_flip() +
    scale_y_continuous(n.breaks = 10)
  
  return(grafica)
}

#### Valores Constantes ####

opacity = 0.9

#### Datos ####

shp_mun<- readOGR("data/municipal.shp") %>% 
  spTransform(CRS("+proj=longlat +datum=WGS84"))

shp_loc <- readOGR("data/loc_urb.shp") %>% 
  spTransform(CRS("+proj=longlat +datum=WGS84"))

shp_mun@data <- select(shp_mun@data, CVEGEO, NOM_ENT, "municipio" = NOMGEO )
shp_loc@data <- select(shp_loc@data, CVEGEOLOC = CVEGEO, NOM_LOC = NOMGEO)

path <- list.files("data/", pattern = ".xlsx", full.names = T)

data <- path %>% 
  excel_sheets() %>% 
  map(function(X) readxl::read_excel(path = path, sheet = X, skip = 5, trim_ws = T)) %>% 
  bind_rows()

names(data) <- c("no", "refugio", "municipio", "direccion", "uso_inmueble",
                 "servicios", "capacidad", "lat", "lng", "alt", "responsable", 
                 "telefono")

#### Procesos únicos ####

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
  ungroup() %>% 
  relocate("alt", .after = last_col()) %>% 
  select(-c(coor1, coor2, d,m,s_int,s_dec, basura, d_lg, 
            m_lg, s_int_lg, s_dec_lg, basura_lg, municipio))


data_coord <- data %>% filter(!is.na(lat))

coordinates(data_coord) <- ~ lng + lat
proj4string(data_coord) <- proj4string(shp_loc)

data <- data_coord %>% 
  point.in.poly(shp_loc) %>% 
  as_tibble() %>% 
  select(no, CVEGEOLOC, localidad = NOM_LOC) %>% 
  rename_with(tolower) %>% 
  right_join(data, by = "no") %>% 
  relocate(refugio, .before = cvegeoloc) %>% 
  relocate(direccion, .after = refugio) %>%
  relocate(cvegeoloc, .after = localidad)

data <- data_coord %>% 
  point.in.poly(shp_mun) %>% 
  as_tibble() %>% 
  select(no, cvegeo = CVEGEO, entidad = NOM_ENT, municipio) %>% 
  right_join(data, by = "no") %>% 
  relocate(entidad, .before = localidad) %>% 
  relocate(municipio, .after = entidad) %>%
  relocate(cvegeo, .before = cvegeoloc) %>% 
  mutate(rankid = row_number()) 
  
pal <- colorFactor(
  palette = c("#9f51dc","#8edc51","#dc5951","#51d3dc"), 
  domain = unique(data$uso_cat)
)


#dis_graph(data)





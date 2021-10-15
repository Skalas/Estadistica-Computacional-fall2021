library(dplyr)
library(rgdal)
library(magrittr)
library(leaflet)
library(readxl)
library(purrr)
library(tidyr)
library(geosphere)
library(spatialEco)
library(ggplot2)
library(rgeos)

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

#### ETL ####

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
  mutate(rankid = row_number()) %>% 
  filter(!is.na(lng))

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

circle_bar_plot <- function(data, shape, municipio) {
  
  #Locating the neighbor municipalities
  #mtx_adj <- gTouches(shape, byid = TRUE)
  
  #Change matrix diagonal for TRUE
  #for(i in 1:ncol(mtx_adj)) {mtx_adj[i,i] <- T}
  #Naming the municipalities in the matrix
  #rownames(mtx_adj) <- shape@data$municipio
  
  #List of neighbor municipalities of chosen municipality
  adj <- rownames(mtx_adj)[mtx_adj[, rownames(mtx_adj) == municipio]]
  
  #Poner sin registro replace_NA stringr
  data <- data %>% 
    group_by(localidad, municipio) %>% 
    tally() %>%
    replace_na(list(localidad = "Desconocido", municipio = "Desconocido")) %>% 
    filter(municipio %in% adj)%>%
    arrange(municipio, n) %>% 
    mutate(etiqueta = paste(n, localidad, sep = ", "), 
           localidad = as.factor(localidad),
           municipio = as.factor(municipio))
  
  empty_bar <- 2
  to_add <- data.frame(matrix(NA, empty_bar * nlevels(data$municipio), ncol(data)) )
  colnames(to_add) <- colnames(data)
  to_add$municipio <- rep(levels(data$municipio), each = empty_bar)
  data <- rbind(data, to_add)
  data <- data %>% arrange(municipio)
  data$id <- seq(1, nrow(data))
  
  # Get the name and the y position of each label
  label_data <- data
  number_of_bar <- nrow(label_data)
  angle <- 90 - 360 * (label_data$id - 0.5) / number_of_bar     
  # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
  label_data$hjust <- ifelse( angle < -90, 1, 0)
  label_data$angle <- ifelse(angle < -90, angle + 180, angle)
  
  # prepare a data frame for base lines
  base_data <- data %>% 
    group_by(municipio) %>% 
    summarize(start = min(id), end = max(id) - empty_bar) %>% 
    rowwise() %>% 
    mutate(title = mean(c(start, end)))
  
  # prepare a data frame for grid (scales)
  grid_data <- base_data
  grid_data$end <- grid_data$end[ c(nrow(grid_data), 1:nrow(grid_data)-1)] + 1
  grid_data$start <- grid_data$start - 1
  grid_data <- grid_data[-1, ]
  
  # Make the plot
  plot <- ggplot(data, aes(x=as.factor(id), y=n, fill=municipio)) +       
    # Note that id is a factor. If x is numeric, there is some space between the first bar
    geom_bar(aes(x = as.factor(id), y = n, fill = municipio), 
             stat = "identity", alpha = 0.5) +
    # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
    geom_segment(data = grid_data, 
                 aes(x = end, y = 40 , xend = start, yend = 40), 
                 colour = "grey", alpha = 1, size = 0.3 , inherit.aes = FALSE ) +
    geom_segment(data=grid_data, aes(x = end, y = 30, xend = start, yend = 30), 
                 colour = "grey", alpha = 1, size = 0.3 , inherit.aes = FALSE) +
    geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), 
                 colour = "grey", alpha = 1, size = 0.3 , inherit.aes = FALSE ) +
    geom_segment(data=grid_data, aes(x = end, y = 10, xend = start, yend = 10), 
                 colour = "grey", alpha = 1, size = 0.3 , inherit.aes = FALSE ) +
    # Add text showing the value of each 100/75/50/25 lines
    annotate("text", x = rep(max(data$id),4), y = c(10, 20, 30, 40), 
             label = c("10", "20", "30","40") , color = "grey", size = 2 , angle = 0, 
             fontface = "bold", hjust = 1) +
    geom_bar(aes(x = as.factor(id), y = n, fill = municipio), stat = "identity", alpha = 0.5) +
    ylim(-40, 40) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.text = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank(),
      plot.margin = unit(rep(-.5,5), "cm") ) +
    coord_polar() + 
    geom_text(data = label_data, aes(x = id, y = n+.5, label = localidad, hjust = hjust), 
              color = "black", fontface = "bold",alpha = 0.6, size = 1.9, 
              angle = label_data$angle, inherit.aes = FALSE ) +
    # Add base line information
    geom_segment(data=base_data, aes(x = start - 0.5, y = -5, xend = end + 0.5, yend = -5), 
                 colour = "black", alpha = 0.8, size = 0.6 , inherit.aes = FALSE) +
    geom_text(data=base_data, aes(x = title+.5, y = -15, label=municipio), 
              colour = "black", alpha = 0.8, size = 2, fontface = "bold", inherit.aes = FALSE)
  
  return(plot)
}

pal <- colorFactor(
  palette = c("#9f51dc","#8edc51","#dc5951","#51d3dc"), 
  domain = unique(data$uso_cat)
)

my_icon = makeAwesomeIcon(
  icon = 'home', 
  markerColor = 'red', 
  iconColor = 'white'
)


#### Valores Constantes ####

opacity = 0.9
mtx_adj <- gTouches(shp_mun, byid = TRUE)
for(i in 1:ncol(mtx_adj)) {mtx_adj[i,i] <- T}
rownames(mtx_adj) <- shp_mun@data$municipio

# Shows Map

# leaflet() %>%
# addTiles() %>%
# addPolygons(data = shp_mun, color = "black") %>%
# addPolygons(data = shp_mun[mtx_adj[rownames(mtx_adj) == "Tepic",],])


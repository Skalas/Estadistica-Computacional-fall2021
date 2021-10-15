library(ggplot2)
library(rgeos)

my_graph<- function(data, shape, municipio) {
  #Data cleaning 
  #Locating the neighbor municipalities
  mtx_adj<-gTouches(shape, byid = TRUE)

  #Change matrix diagonal for TRUE
  for(i in 1:ncol(mtx_adj)) {mtx_adj[i,i]<-T
  }
#Naming the municipalities in the matrix
  rownames(mtx_adj)<-shape@data$municipio

#List of neighbor municipalities of chosen municipality
  adj<-shape[mtx_adj[rownames(mtx_adj)==municipio,],] %>% as_tibble() %>% pull(municipio)

#Shows map
#shp_mun[mtx_adj[rownames(mtx_adj)=="Tepic",],] %>% leaflet()%>% addTiles()%>% addPolygons(data = shp_mun, color = "black") %>% addPolygons()

#Poner sin registro replace_NA stringr
  data <- data %>% group_by(localidad, municipio) %>% 
                 tally() %>%
                 replace_na(list(localidad = "Desconocido", municipio=  "Desconocido")) %>% 
                 filter(municipio%in%adj)%>%
                 arrange(municipio, n) %>% 
                 mutate(etiqueta=paste(n,localidad, sep = ", "), 
                        localidad=as.factor(localidad),
                        municipio=as.factor(municipio))
         
  empty_bar <- 2
  to_add <- data.frame(matrix(NA, empty_bar*nlevels(data$municipio), ncol(data)) )
  colnames(to_add) <- colnames(data)
  to_add$municipio <- rep(levels(data$municipio), each=empty_bar)
  data <- rbind(data, to_add)
  data <- data %>% arrange(municipio)
  data$id <- seq(1, nrow(data))

# Get the name and the y position of each label
  label_data <- data
  number_of_bar <- nrow(label_data)
  angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
  label_data$hjust <- ifelse( angle < -90, 1, 0)
  label_data$angle <- ifelse(angle < -90, angle+180, angle)

# prepare a data frame for base lines
  base_data <- data %>% 
  group_by(municipio) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

# prepare a data frame for grid (scales)
  grid_data <- base_data
  grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
  grid_data$start <- grid_data$start - 1
  grid_data <- grid_data[-1,]


# Make the plot
  p <- ggplot(data, aes(x=as.factor(id), y=n, fill=municipio)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  
  geom_bar(aes(x=as.factor(id), y=n, fill=municipio), stat="identity", alpha=0.5)+
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 40 , xend = start, yend = 40), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 30, xend = start, yend = 30), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE) +
  geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 10, xend = start, yend = 10), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  


  # Add text showing the value of each 100/75/50/25 lines
  annotate("text", x = rep(max(data$id),4), y = c(10, 20, 30, 40), label = c("10", "20", "30","40") , color="grey", size=2 , angle=0, fontface="bold", hjust=1) +
  
  geom_bar(aes(x=as.factor(id), y=n, fill=municipio), stat="identity", alpha=0.5) +
  ylim(-40,40) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-.5,5), "cm") 
  ) +
  coord_polar() + 
  geom_text(data=label_data, aes(x=id, y=n+.5, label=localidad, hjust=hjust), color="black", fontface="bold",alpha=0.6, size=1.9, angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  geom_segment(data=base_data, aes(x = start-.5, y = -5, xend = end+.5, yend = -5), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE) +
  geom_text(data=base_data, aes(x = title+.5, y = -15, label=municipio), colour = "black", alpha=0.8, size=2, fontface="bold", inherit.aes = FALSE)
 
  p

}


############################################################
#### FUNCIONES RELACIONADAS CON EL ETL #####################
############################################################

###########################################
### En esta parte se debe ingresar el token de la API de Google para 
TOKEN<-"TOKEN"
###########################################


# En esta seccion para el ETL se usan dos funciones.
# En primer lugar import_data para importar, acomodar, limpiar e inputar datos
# En segundo lugar coord_to_float para transformar las coordenadas a un formato mas amigable para leaflet


import_data <- function() {
  
  #Esta función tiene como objetivo importar, acomodar y limpiar los datos.
  
  #Parte I: Descarga a partir de un excel
  
  #Aqui se pone la ubicación de los datos
  file <- 'data/refugios_nayarit.xlsx'
  refugios <- data.frame()
  for (i in 1:length(excel_sheets(file))){
    refugios <- rbind(refugios,head(read.xlsx(file, sheet= i, startRow = 7, colNames = F),-1))
  }
  
  colnames(refugios) <- c('id',
                          'refugio',
                          'municipio',
                          'calle',
                          'uso',
                          'servicios',
                          'capacidad',
                          'coordN',
                          'coordW',
                          'altitud',
                          'responsable',
                          'telefono')
  #Parte 2: Limpieza
  
  #_____________ LIMPIEZA TELEFONOS
  #_____________
  refugios<-refugios %>% mutate(NEXTEL=ifelse(str_detect(telefono,"NEXTEL"),1,0),
                                aux_tel= str_remove_all(telefono,"[A-Z]|[.]|[-]|[:]|[,]"),
                                #telefono1=str_extract(aux_tel,"[0-9]"),
                                vector_telef=stri_extract_all(aux_tel,regex="[0-9]{0,2}[*]{0,1}[0-9]{6,12}[*]{0,1}[0-9]{0,2}"),
                                tel1=as.character(lapply(vector_telef, `[`, 1)),
                                tel2=as.character(lapply(vector_telef, `[`, 2)),
                                tel3=as.character(lapply(vector_telef, `[`, 3)),
                                tel4=as.character(lapply(vector_telef, `[`, 4)),
                                
                                #correccion ad hoc para numeros nextel
                                nextel=ifelse(NEXTEL==1,tel2,NA),
                                tel2=ifelse(NEXTEL==1,NA,tel2))
  refugios$NEXTEL<-NULL
  refugios$vector_telef<-NULL
  refugios$aux_tel<-NULL
  refugios$telefono<-NULL
  
  #_____________ LIMPIEZA COORDENADAS
  #_____________
  refugios<- refugios %>% mutate(
    ### para coordN
    
    coordN1=stri_extract_all(coordN,regex="[0-9]{2,3}"),
    coordN2=paste(as.character(lapply(coordN1, `[`, 1)),
                  as.character(lapply(coordN1, `[`, 2)),sep = "º"),
    coordN3=paste(as.character(lapply(coordN1, `[`, 4)),"\"", sep = ""),
    coordN4=paste(as.character(lapply(coordN1, `[`, 3)),coordN3, sep="."),
    coordN=paste(coordN2,coordN4, sep="\'"),
    
    ### para coordW
    coordW1=stri_extract_all(coordW,regex="[0-9]{2,3}"),
    coordW2=paste(as.character(lapply(coordW1, `[`, 1)),
                  as.character(lapply(coordW1, `[`, 2)),sep = "º"),
    coordW3=paste(as.character(lapply(coordW1, `[`, 4)),"\"", sep = ""),
    coordW4=paste(as.character(lapply(coordW1, `[`, 3)),coordW3, sep="."),
    coordW=paste(coordW2,coordW4, sep="\'"),
    
    ## Agrego NAs a las columnas con algun valor en NA y a su coordenada pareja
    coordN=ifelse(str_detect(coordN,"NA"),NA,coordN),
    coordW=ifelse(str_detect(coordW,"NA"),NA,coordW),
    coordN=ifelse(str_detect(coordW,"NA"),NA,coordN),
    coordW=ifelse(str_detect(coordN,"NA"),NA,coordW),
    
    #_____________ LIMPIEZA GENERAL
    #_____________
     ##### Limpieza de coordenadas volteadas
    coord_aux= coordN,
    coordN= ifelse(str_detect(coordN,"[0-9]{3}º"),coordW,coordN),
    coordW= ifelse(str_detect(coord_aux,"[0-9]{3}º"),coord_aux,coordW)

  )
  refugios$coord_aux<-NULL
  
  refugios$coordN1<-NULL
  refugios$coordN2<-NULL
  refugios$coordN3<-NULL
  refugios$coordN4<-NULL
  
  refugios$coordW1<-NULL
  refugios$coordW2<-NULL
  refugios$coordW3<-NULL
  refugios$coordW4<-NULL
  
  #Parte III. Imputacion
  #_____________ 
  #_____________
  
  ##### Relleno de coordenadas faltantes con google API ######
  new_DF <- refugios[is.na(refugios$coordN),]
  #################################################################################PONER LLAVE API DE GOOGLE
  register_google(key = TOKEN, write = TRUE) #registro de llave

  cc <- map_df(1:nrow(new_DF), ~ geocode(paste(new_DF$refugio[.],new_DF$municipio[.] ,"Nayarit México", sep=" "))) #crea df de coordenadas faltantes 
  
  refugios[is.na(refugios$coordN), ]$coordN <- cc$lat #rellelna latitud
  refugios[is.na(refugios$coordW), ]$coordW <- abs(cc$lon) #rellena longitud
  
  ###############
  ## Cambio de coordenadas a strings ## 
  
  refugios$coordN <- as.character(refugios$coordN)
  refugios$coordW <- as.character(refugios$coordW)
  

  return(refugios)
}

coord_to_float<-function(data){
  
  #Esta función tiene el objetivo de convertir en numerico las coordenadas
  #Sin embargo en la base de datos contamos con las ubicaciones en coordenada y en numero debido a que la API de google las imputa en numerico
  #Por ello, tenemos que dividir la base en dos para cada tipo de ubicación y luego las juntamos.
  
  #Parte I: DIVISION EN 2
  
  # Dataset con coordenadas en grados
  good_subset<- data %>% filter(str_detect(coordN,"\\'"))
  
  # Dataset con coordenadas en numero
  
  a<-unique(data$id)
  b<-unique(good_subset$id)
  c<-setdiff(a, b)
  
  trouble_subset<- data %>% filter(id %in% c)
  
  #Parte II: CONVERSION DE GRADO A NUMERICO
  
  good_subset$coordN <- substr(good_subset$coordN,1,nchar(good_subset$coordN)-1)
  good_subset$coordW <- substr(good_subset$coordW,1,nchar(good_subset$coordW)-1)
  
  good_subset <- good_subset %>% mutate(
    w = as.double(map(strsplit(good_subset$coordW,"([º,'])"),1)) + #grados
      as.double(map(strsplit(good_subset$coordW,"([º,'])"),2))/60 + #minutos
      round(as.double(map(strsplit(good_subset$coordW,"([º,'])"),3)))/3600, #segundos
    n = as.double(map(strsplit(good_subset$coordN,"([º,'])"),1)) + 
      as.double(map(strsplit(good_subset$coordN,"([º,'])"),2))/60 + 
      round(as.double(map(strsplit(good_subset$coordN,"([º,'])"),3)))/3600)
  
  #Parte III: ADECUACION DE LA BASE EN NUMERICO 
  
  trouble_subset<-trouble_subset %>% mutate(
    w=coordW,
    n=coordN)
  
  #Parte IV: MERGE DE AMBAS BASES
  
  data<-as.data.frame(rbind(good_subset,trouble_subset))
  data$w<-as.numeric(data$w)
  data$n<-as.numeric(data$n)
  
  data  
}



############################################################
#### FUNCIONES RELACIONADAS CON EL MOTOR Y EL DASHBOARD ####
############################################################

# En esta parte se muestran 3 funciones: 
# motor_refugio_cercano que simplemente devuelve datos del refugio más cercano dadas una ubicacion.
# paint_map que simplemente realiza un mapa en leaflet dadas unas coordenadas
# motor_refugios_municipio_map que devuelve un mapa con todas las ubicaciones de refugios en un municipio determinado

motor_refugio_cercano <- function (long,lat){
  # Esta función regresa informacion sobre refugio más cercano dependiendo de la longitud y latitud dadas en numerico.
  # Esta funcion se corre después de tener el dataframe final posterior a las limpiezas
  long<-abs(long)
  lat<-abs(lat)
  data <- data %>% mutate(distancia = distVincentyEllipsoid(c(long,lat),  data[,c('w','n')])/1000) #en km
  head(data[order(data$distancia,decreasing = FALSE),],1) %>% select(w,n,id,municipio)
}


paint_map <- function(long,lati){
  leaflet() %>%
  addTiles() %>%  
  addMarkers(lng=long, lat=lati)
}

motor_refugios_municipio_map <- function(mun) {
  #Esta función realiza un mapa de todos los refugios de una municipalidad
  
  coord <- data %>% filter(municipio==mun) %>% select(w,n) 
  output <- leaflet() %>%
    addTiles() %>%  
    addMarkers(lng=-coord[[1]], lat=coord[[2]])
  output  # Imprime el mapa
  
}








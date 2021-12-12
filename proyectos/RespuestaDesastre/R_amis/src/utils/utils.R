library(openxlsx)
library(purrr)
library(tidyverse)
library(geosphere)
library(psych)

#---------- Functions to load data (Extract)

load_df <- function(){
  #Get data from .xlsx file
  #args: none
  #path: needs the route and file name 
  #returns: a data frame with all observations
  Ruta_archivo = "./data/refugios_nayarit.xlsx"
  hojas = getSheetNames(Ruta_archivo)
  lista_df = map(hojas,function(x){
    read.xlsx(Ruta_archivo ,sheet = x, startRow = 7, colNames = FALSE)
  })
  df = do.call(rbind,lista_df)
  names(df) = c("num","refugio","municipio","direccion","uso_inmueble","servicios","capacidad","lat",
                "long","altitud","responsable","telefono")
  return(df)
}

#----------- Functions for EDA

mode <- function(x) {
  #Get mode of data
  #args:
  #x (map column): data that is being analyzed
  #returns:
  #mode of data###
  return(names(which.max(table(x))))
}

count_data <- function(df){
  #Counting number of variables and obs in the data and summarise
  #args:
  #data (dataframe): data that is being analyzed
  #returns:
  #print : number of variables and obs in the data###
  res_frame <- data.frame(
    tipo_dato = unlist(lapply(df, class)),
    cantidad = sapply(df, function(x) sum(!is.na(x))),
    nulos_o_na = apply(is.na(df), 2, sum),
    unicos = sapply(df, function(x) length(unique(x))),
    moda = sapply(df, function(x) mode(x))
  )
  print(res_frame)
}

global_panoram <- function(df){
  #Counting number of variables and obs in the data and summarise
  #args:
  #data (dataframe): data that is being analyzed
  #returns:
  #print : global panoram of data###
  nans <-sum(apply(is.na(df), 2, sum))
  total <- data.frame(columnas = length(colnames(df)),
                      registros = nrow(df),
                      total_NAs = nans)
  type <- data.frame(table(unlist(lapply(df, class))))
  total<-cbind(total,pivot_wider(type, names_from = Var1, values_from = Freq))
  print(total)
}

data_profiling <- function(df, type_var){
  
  #Create the data profiling of categorical variables.
  #args:
  #data (dataframe): data that is being analyzed
  #type_var (str): str with variable name.
  #returns:
  #profiling_frame: Dataframes with info.
  
  profiling_frame <- data.frame()
  
  if(type_var == "character"){
    
    pro_df <- df %>% select_if(is.character)
    
    profiling_frame <- data.frame(
      registros = sapply(pro_df, function(x) sum(!is.na(x))),
      nulos_o_na = apply(is.na(pro_df), 2, sum),
      categorias = sapply(pro_df, function(x) length(unique(x))),
      moda = sapply(pro_df, function(x) mode(x))
    )
  }
  
  
  if(type_var == "numeric"){
    
    pro_df <- df %>% select_if(is.numeric)
    
    profiling_frame <- data.frame(
      registros = sapply(pro_df, function(x) sum(!is.na(x))),
      nulos_o_na = apply(is.na(pro_df), 2, sum),
      categorias = sapply(pro_df, function(x) length(unique(x))),
      moda = sapply(pro_df, function(x) mode(x)),
      min = apply(pro_df, 2, min, na.rm=TRUE),
      max = apply(pro_df, 2, max, na.rm=TRUE),
      mean =  apply(pro_df, 2, mean, na.rm=TRUE),
      variance =  apply(pro_df, 2, var, na.rm=TRUE),
      stdv =  apply(pro_df, 2, sd, na.rm=TRUE),
      quantile25 =  apply(pro_df, 2, quantile, probs=c(.25), na.rm=TRUE),
      median =  apply(pro_df, 2, median, na.rm=TRUE),
      quantile75 =  apply(pro_df, 2, quantile, probs=c(.75), na.rm=TRUE),
      kurtosis = apply(pro_df, 2, kurtosi, na.rm=TRUE),
      skewness = apply(pro_df, 2, skew, na.rm=TRUE)
    )
  }
  
  return(as.data.frame(t(profiling_frame)))
}

#---------- Cleaning and Transform functions

trim <- function (x){
  #trim withspace
  #args:
  #x (vector): data that is being analyzed
  #returns:
  #vector: vector wirh trim cases###
  
  if(is.character(x))return(gsub("^\\s+|\\s+$", "", x)) else return(x)
}

first.transform.data <- function(df){
  #Many functions to first transform date
  #args:
  #data (Data Frame): data set into Dataframe.
  #returns:
  #df (dataframe): to transform data###
  
  df <- data.frame(lapply(df, function(v) {if (is.character(v)) return(tolower(v))else return(v)}))
  df <- data.frame(lapply(df, function(x) trim(x)))
  return(df) 
}

split_num <- function(x){
  #Function for cleaning longitud and latitud
  #args:
  #x (longitud or latitud column): data to be cleaned
  #returns:
  #a new column with longitud or latitud already cleaned 
  vec = unlist(strsplit(x,""))
  if(length(vec) == 11){
    cadena = paste(vec[1],vec[2],"-",vec[4],vec[5],"-",vec[7],vec[8],".",vec[10],vec[11], sep = "")
    return(cadena)
  } 
  else {
    return(paste("verificar",x))
  }
}

split_num2 <- function(x){
  #Function for cleaning longitud and latitud
  #args:
  #x (longitud or latitud column): data to be cleaned
  #returns:
  #a new column with longitud or latitud already cleaned 
  vec = unlist(strsplit(x,""))
  if(length(vec) == 12){
    cadena = paste(vec[1],vec[2],vec[3],"-",vec[5],vec[6],"-",vec[8],vec[9],".",vec[11],vec[12], sep = "")
    return(cadena)
  } 
  else {
    return(paste("verificar",x))
  }
}

data_clean <- function(df){
  #Make some adecuations to interest variables (latitude and longitude) and 
  #args: a data frame cointaining this two variables 
  #returns: the same data frame with columns "lat" and "long" in the required format
  #         and a new data frame withe registry that needs verification (those are eliminated from the original data frame) 
  df = df[order(df$num,na.last = FALSE),]
  df <- df[!is.na(df$num),]
  df$lat = str_replace_all(df$lat," ","")
  df$lat = str_replace_all(df$lat,"[\"]","")
  df$long = str_replace_all(df$long," ","")
  df$long = str_replace_all(df$long,"[\"]","")
  df$lat = map_chr(df$lat, ~ split_num(.x))
  df$long = map_chr(df$long, ~ split_num2(.x))
  verificar = df %>% filter(str_detect(lat, "^verificar") | str_detect(long, "^verificar"))
  df = df[!(df$num %in% (verificar$num)), ]
  row.names(df) <- NULL
  return(list(df,verificar))
}

var_lat_lon <- function(df){
  # Transforms degrees, minutes and seconds to decimal degrees 
  #args:
  #df (dataframe): dataframe that contains the columns to be transformed
  #returns:
  #a dataframe with the new new columns in decimal degrees
  dummy_lat = data.frame(df$lat) %>% separate(df.lat,c("A","B","C"),sep = "([-])")
  dummy_long = data.frame(df$long) %>% separate(df.long,c("A","B","C"),sep = "([-])")
  dummy_lat$A = as.numeric(dummy_lat$A)
  dummy_lat$B = as.numeric(dummy_lat$B)
  dummy_lat$C = as.numeric(dummy_lat$C)
  dummy_lat = dummy_lat %>% mutate(latitud = A + B/60 + C/3600)
  dummy_long$A = as.numeric(dummy_long$A)
  dummy_long$B = as.numeric(dummy_long$B)
  dummy_long$C = as.numeric(dummy_lat$C)
  dummy_long = dummy_long %>% mutate(longitud = -1*(A + B/60 + C/3600))
  df = cbind(df,dummy_lat[4],dummy_long[4])
  return(df)
}

#------------- Search engine

distancia <- function(df,longitude,latitude,p1,p2){
  #Calculate the distance between a fixed point and all the cordinates
  #in the data
  #args:
  #df (dataframe): data contaning longitud and latitude
  #longitud (column name): data containing the refuges longitudes  
  #latitud (column name): data containing the refuges latitudes
  #p1 (double): latitude point in decimal degrees from wich the distance will be calculated  
  #p2 (double): longitude point in decimal degrees from wich the distance will be calculated
  #returns:
  #distanvector that contains the distance from a fixed point to all the points in the dataframe
  distan <- c()
  for (x in 1:nrow(df)){
    r <- distHaversine(c(p1,p2),c(df$longitud[x],df$latitud[x]))
    distan[x] <- r
  }
  return(distan)
}

ref_cerc <- function(df,p_long,p_lat){
  # Order the data frame to list the 7 nearest refugees to a given point
  # args: the cleaned data frame with adecuate lat and long formats
  #       two points in decimal format (latitude and longitude) from wich distance to each refugee is calculated
  #reurns: a data frame with the 6 nearest refugees to the given point (lat,long)
  df = cbind(df,dist_p = distancia(df,longitude,latitude,p_long,p_lat))
  top_7 = head(order(df$dist_p),7)
  cercanos = df[top_7,]
  return(cercanos)
}



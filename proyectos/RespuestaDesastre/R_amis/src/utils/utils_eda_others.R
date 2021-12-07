library(openxlsx)
library(purrr)
library(tidyverse)
library(psych)


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

get_variables <- function(df){
  
  #Get type and columns variables
  #args:
  #data (dataframe): data that is being analyzed
  #returns:
  #list :with column and type of variable###
  df <- df %>% select_if(is.numeric) %>% names()
  
  return(df)
}

top_data <- function(x, df, top){
  
  df %>% group_by(x) %>% summarise(n=n()) %>% arrange(desc(n)) %>% slice_head(n=3) %>% filter(row(municipUn) == top)
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
















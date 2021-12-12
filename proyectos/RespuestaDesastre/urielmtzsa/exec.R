##### Instalación y carga de paqueterías

# Librerías a utilizar. Si no se tiene alguna, se instala.
pack_u<-c("rstudioapi","readxl","dplyr","knitr","kableExtra","ggplot2","tidyr","leaflet","rgdal","shiny","osrm","rdist")
pack_u_installed<-pack_u %in% installed.packages()
pack_u_uninstalled<-pack_u[pack_u_installed==FALSE]
install.packages(pack_u_uninstalled)
lapply(pack_u, require, character.only = TRUE)

##### Establecer directorio de trabajo. 

# Se estable el directorio de trabajo como la carpeta donde se encuentre el archivo .R
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) 

##### Ejecución de ETL

source(paste(getwd(),"/proyecto1_etl.R",sep=""))

##### Ejecución de análisis exploratorio

out_path<-rmarkdown::render(
  paste(getwd(),'/proyecto_1_eda.Rmd',sep=""))
browseURL(out_path)

##### Ejecución de app

runApp(paste(getwd(),sep=""),
       launch.browser = FALSE,
       host="0.0.0.0",
       port=9999
)


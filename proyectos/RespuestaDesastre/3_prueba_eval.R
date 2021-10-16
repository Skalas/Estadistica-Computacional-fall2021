
############################################################
#### SCRIPT DE PRUEBA-EVALUACION ###########################
############################################################

#Este script es un archivo auxiliar en la evaluacion y ademas sirve para probar las funciones antes de ponerlas en la app.
#si lo que se quiere es evaluar a detalle los pasos de la tarea este script es muy util.
# En este script se muestra de manera muy clara y directa cada aspecto preguntado.
# Ademas, este script resume todo lo que pasa detrás de nuestra shiny app.

# Archivos necesarios:

source("1_packages.R")
source("2_functions.R")


# Necesidades de Negocio.

#1. Un [Etl](https://en.wikipedia.org/wiki/Extract,_transform,_load) en R que tome los datos del formato en Excel y los transforme en un Data Frame que sea utilizable para análisis. (Ojo, el ETL tiene que asumir que puede pasar que le agreguen hojas al archivo de excel.)

data <- import_data() %>% coord_to_float()


#2. Generar un motor sencillo que me indique el refugio más cercano a una coordenada dada.

# Metemos las coordenadas del refugio con id 1: PRIMARIA LABOR Y CONSTANCIA  en ACAPONETA 

  # Datos
  (ref<-motor_refugio_cercano(-105.3603,22.49889))

  # Mapa
  paint_map(-ref[[1]],ref[[2]])
  
  #Tabla
  tabla_p1<-data %>% 
    filter(id==ref[[3]]) %>% 
    select(-coordN,-coordW,-altitud) 


#3. Generar un dashboard que me ayude a identificar por localidad los refugios existentes.
  
  # tabla
  tabla_p3<-data %>% 
    filter(municipio==ref[[4]]) %>% 
    select(-coordN,-coordW,-altitud) 
  
  # mapa
  motor_refugios_municipio_map(ref[[4]])

# 4. Generar que el input de las coordenadas se maneje desde el dashboard.
  
  # Para esta parte integramos unos campos en la app que solicitan información al usuario
  # Posteriormente se solicita a la API de google información sobre las coordenadas de la ubicación que puso el usuario
  # Con esa ubicación se corren en vivo las funciones mostradas en este script.
  
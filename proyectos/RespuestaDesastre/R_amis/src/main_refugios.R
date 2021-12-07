# *** Primer paso: extraer información geográfica ***
# Previamente se ha de ejecutar el archivo imports_initial.sh
# desde una terminal de linux (puede ser WSL); ubicarse en linux la carpeta
# dentro del mismo directorio donde se encuentra este archivo y posteriomente
# ejecutar el siguiente comandod:
# bash imports_initial.sh
# Nota: posiblemente se solicite una contraseña para instalar rgdal.

# *** Segundo paso: preprocesar la información ***
# Ejecutar la siguiente línea
source("./src/etl/etl.R" , encoding = 'UTF-8')

# *** Tercer paso: configuraciones globales ***
# Ejecutar la siguiente línea
source("./map_refugios/global.R" , encoding = 'UTF-8')

# *** Cuarto paso: abrir la aplicación ***
# Ejecutar la siguiente línea
shiny::runApp('./map_refugios/app.R')

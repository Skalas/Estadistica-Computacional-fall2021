#!/bin/bash

#Archivo de salida: carga_base.sh

# se filtan los datos que contienen el producto Manzana y se construye un archivo con la instruccion CURL para cargar todos los registros a la base de datos

grep --binary-file=text "Manzana" ./Bash/datos/agricola_1980_2019.csv | awk \
' BEGIN{FS=","; OFS="," } \
{ printf("curl -X POST -H \"Content-Type: application/json\" -d \47[{ \
\"Anio\":\"%s\", \
\"Idestado\":\"%s\", \
\"Nomestado\":\"%s\", \
\"Idciclo\":\"%s\", \
\"Nomcicloproductivo\":\"%s\", \
\"Idmodalidad\":\"%s\", \
\"Nommodalidad\":\"%s\", \
\"Idunidadmedida\":\"%s\", \
\"Nomunidad\":\"%s\", \
\"Idcultivo\":\"%s\", \
\"Nomcultivo\":\"%s\", \
\"Sembrada\":\"%s\", \
\"Cosechada\":\"%s\", \
\"Siniestrada\":\"%s\", \
\"Volumenproduccion\":\"%s\", \
\"Rendimiento\":\"%s\", \
\"Precio\":\"%s\"}]\47 0.0.0.0:8080/carga \n ",$1,$2,$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17) }  ' > ./Bash/carga_base.sh

#se cambian los permisos de ejecucion al archivo generado

chmod +x ./Bash/carga_base.sh


 











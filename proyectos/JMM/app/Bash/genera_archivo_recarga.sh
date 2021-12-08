#!/bin/bash

#arhcivo de entrada: datos.csv

#archivo de salida: recarga_datos.csv

# Se lee el archivo datos_recarga.csv que contiene los registros que se desean recargar, se filtran los registros de produccion de manzana y se construye el archivo CURL para procesarlo

grep --binary-file=text "^[0-9]" < datos_recarga.csv | awk  ' BEGIN{FS=","; OFS="," } {print $1,$2,$3,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}' |  grep --binary-file=text "Manzana" | awk \
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
\"Precio\":\"%s\"}]\47 0.0.0.0:8080/carga \n ",$1,$2,$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17) }  ' > ./Bash/recarga_datos.sh

#se cambian los permisos de ejecuacion al archivo generado

chmod +x ./Bash/recarga_datos.sh


 











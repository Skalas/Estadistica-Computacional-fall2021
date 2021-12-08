#!/bin/bash

#arhcivo de entrada: predice.csv

#archivo de salida: carga_predict.csv

# Se lee el archivo predice.csv que contiene los registros que se desean predecir, se filtran los registros de produccion de manzana y se construye el archivo CURL para procesarlo

grep --binary-file=text "^[0-9]" < predice.csv | awk  ' BEGIN{FS=","; OFS="," } {print $1,$2,$3,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}' |  grep --binary-file=text "Manzana" | awk \
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
\"Precio\":\"%s\"}]\47 0.0.0.0:8080/carga_pred \n ",$1,$2,$2,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,"0",$16,$17) }  ' > ./Bash/carga_predict.sh

#se cambian los permisos de ejecuacion al archivo generado

chmod +x ./Bash/carga_predict.sh





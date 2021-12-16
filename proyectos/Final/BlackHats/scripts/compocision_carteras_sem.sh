#!/bin/bash

################################
#      II. Lista URLS          #
################################

# Realizo una lista de los pdfs a extraer

declare -a ListaPDFS=(

"https://invex.com/getmedia/b3ea7101-b018-4c67-bb52-8dbd2ed4facd/CARSEM_INVEXCP?ext=.pdf",
"https://invex.com/getmedia/fd80fe33-3556-4dfe-9109-b6e5070566d6/CARSEM_INVEXLP?ext=.pdf",
"https://invex.com/getmedia/620692bd-4d96-4bc2-8ec5-8592e44f1219/CARSEM_INVEXMP?ext=.pdf",

"https://invex.com/getmedia/a9766ad5-c903-4281-b5aa-c61ffc922d66/CARSEM_INVEXMX?ext=.pdf",
"https://invex.com/getmedia/c384ef45-2fa9-403d-a3f5-17bced9e5a90/CARSEM_INVEXTK?ext=.pdf",
"https://invex.com/getmedia/03789c49-8ea5-44bc-a3e8-cee32be5ed30/CARSEM_INVEXCR?ext=.pdf",
"https://invex.com/getmedia/b2649995-72fe-46d3-8481-7bbaaeb4e352/CARSEM_INVEXIN?ext=.pdf",

"https://invex.com/getmedia/9a14681a-eb32-47cb-9e9a-cf4adb15ff66/CARSEM_INVEXCO?ext=.pdf")

################################
#      III. Extraccion         #
################################

for val in ${ListaPDFS[@]}; do


## Extraigo el pdf de internet

curl -o sourcedoc.pdf $val


## Extraigo el texto del pdf

pdftotext -layout sourcedoc.pdf file.txt


## VACIADO VARIABLES 

# Extraigo nombre del fondo
name=$(sed -n '1p' file.txt | grep -Po '[A-Z]*')

# Extraigo día mes y año 
date=$(sed -n '4p' file.txt | grep -Po '[0-9].*')

# agrego al principio de la tabla extraida
c="${name}   ${date}"

# obtengo de cada linea solo aquellas que empiezan con una serie
# pego dos columnas con la fecha y el nombre
grep -v -e '^$' file.txt | grep -P '^ *[A-Z0-9]{1,2} ' | awk -v prefix="$c" '{print prefix $0}' |  tr -s ' ' >> composicion_invex_s.txt

done

################################
#      III. Vaciado         #
################################
## Se quitan lineas que no tuvieron las columnas totales (errores de captura) generalmente son menos que 5

cat composicion_invex_s.txt |  tr -s ' ' > composicion_invex_sem_preliminar.txt
rm composicion_invex_s.txt
cat  composicion_invex_sem_preliminar.txt | grep -P '.*[[:space:]].*[[:space:]].*[[:space:]].*[[:space:]].*[[:space:]].*[[:space:]].*[[:space:]].*'> composicion_invex_sem.txt
rm composicion_invex_sem_preliminar.txt



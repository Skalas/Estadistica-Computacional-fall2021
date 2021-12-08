#!/bin/bash

################################
#      II. Lista de URLS       #
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
sed -n '1p' file.txt | grep -Po '[A-Z]*'  >> carteras_invex_s.txt

# Extraigo día mes y año 
sed -n '4p' file.txt | grep -Po '[0-9].*' >> carteras_invex_s.txt

# extraigo calificacion
sed -n '5p' file.txt  | grep -q "CALI" && (sed -n '5p' file.txt  | grep -Po 'CALIFICACION: \K.*' >> carteras_invex_s.txt ) || (echo "sin_calif" >> carteras_invex_s.txt)

# extraigo valor total
grep -v -e '^$' file.txt | tail -n 20| sed -n -e '/CARTERA TOTAL/,/Valor en Riesgo/ p; /Valor en Riesgo/q'|head -n 3 | grep -Po 'CARTERA TOTAL: *\K[0-9].* ' >> carteras_invex_s.txt

#extraigo var establecido
grep -v -e '^$' file.txt | tail -n 20| sed -n -e '/CARTERA TOTAL/,/Valor en Riesgo/ p; /Valor en Riesgo/q'|head -n 3 | grep -Po 'ESTABLECIDO: *\K[0-9].*' | sed 's/ //g' >> carteras_invex_s.txt

#extraigo var promedio
grep -v -e '^$' file.txt | tail -n 20| sed -n -e '/CARTERA TOTAL/,/Valor en Riesgo/ p; /Valor en Riesgo/q'|head -n 3 | grep -Po 'OBSERVADO PROMEDIO: *\K[0-9].*' | sed 's/ //g' >> carteras_invex_s.txt

################################
#      IV. Vaciado.            #
################################
done

cat carteras_invex_s.txt | awk '{print}' ORS=' '|  tr -s ' '| xargs -n 6 > carteras_invex_sem.txt
rm carteras_invex_s.txt







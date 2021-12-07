#!/usr/bin/env bash

mkdir data
cd data
mkdir estados
mkdir municipios

# Se intentó descargar el archivo de forma programática, pero nos tomó demasiado tiempo
# y se descargaa un formato no reconocido, por lo que decidimos dejar los datos en la carpeta.
#curl -o refugios_nayarit.xlsx https://docs.google.com/spreadsheets/d/0Bw4a10rhk2QqaTZkUmQwaXU4aEE/edit?resourcekey=0-RQa9gRpFX0x3z5bSJGn0Dg#gid=752349143

curl -o estados.zip https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marc_geo/702825292812_s.zip

sudo apt-get install gdal-bin

unzip estados.zip
unzip mge2010v5_0.zip
unzip mgm2010v5_0.zip

mv Entidades* estados
mv Municipios* municipios

cd estados
ogr2ogr states.shp Entidades_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

cd ../municipios
ogr2ogr municip.shp Municipios_2010_5.shp -t_srs "+proj=longlat +ellps=WGS84 +no_defs +towgs84=0,0,0"

cd ../

rm estados.zip mgau2010v5_0.zip mge2010v5_0.zip mglr2010v5_0.zip mglu2010v5_0.zip mgm2010v5_0.zip

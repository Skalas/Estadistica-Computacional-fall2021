#!/bin/bash

#Archivo para hacer una carga inicial completa a la base de datos



python3 ./python/crea_tablas.py

sh ./Bash/descarga_limpia_datos.sh
sh ./Bash/genera_archvo_carga.sh
sh ./Bash/carga_base.sh



# Refugios: Desastres Naturales

## Autor

Uriel Martínez Sánchez

## Resumen

A partir de información de refugios de Nayarit dada en un excel, se crea un etl para extracción de información. Se realiza un documento que explica paso a paso lo hecho por el etl y un sencillo análisis exploratorio. Se realiza una app en shiny para encontrar el refugio más cercano dada una ubicación dada, además de proporcionar información del refugio al usuario.

## Organización de la carpeta

* El archivo **exec.R** ejecuta los archivos **proyecto1_etl.R** -> **proyecto_1_eda.Rmd** -> **app.R** en ese orden. Este archivo carga las librerías necesarias y ajusta el directorio de trabajo, sin embargo, cada archivo tiene las mismas líneas repetidas para carga de librerías y directorio de trabajo por si se requieren ejecutar de manera separada.
* El archivo **proyecto1_etl.R** realiza la conversión de la información de una archivo excel a un dataframe manejable. Si el archivo excel se localiza en un directorio diferente al dado por default (directorio donde se encuentren los archivos .R y .Rmd) o alguna variable del ETL cambia, en este archivo es donde se deben hacer las corrrecciones necesarias.
* El archivo **proyecto_1_eda.Rmd** muestra un resumen de los pasos hechos para crear el ETL y un pequeño análisis exploratorio. Este archivo es independiente a todos los demás, los cambios hechos en **proyecto1_etl.R** también se deben hacer en este. Este archivo arroja un html llamado **proyecto_1_eda.html**.
* El archivo **app.R** muestra el dashboard realizado para mostrar los refugios más cercanos para el usuario. Notar que este archivo depende del archivo **proyecto1_etl.R**, el cual se ejecuta automáticamente al ejecutar la app.

## Docker

Adicionalmente se creó un sencillo repositorio en docker para la ejecución de la app.
* El archivo **Dockerfile** muestra cómo se creó la imagen, la cual se basa en [rocker/rstudio](https://hub.docker.com/r/rocker/rstudio) y se le añadieron los requerimientos de sistema y paqueterías necesarias para la ejecución de la app.
  * Notar que en este contenedor se cargaron: el excel que utiliza el ETL y los archivos necesarios para la carga de los mapas.
  * Notar que se utilizan los archivos **exec_.R**, **proyecto1_etl_.R**, **proyecto_1_eda_.Rmd**, **app_.R** que difieren de los originales sólo en el cambio de directorio al meter todos los archivos a una carpeta llamada */project_1/*
* El archivo **install_packages.R** se utiliza para la carga de paqueterías en R necesarias para la ejecución.

Si existen problemas para replicar el proceso con los archivos mencionados en la sección **Organización de la carpeta**, se pueden ejecutar las siguietes líneas:
```
docker pull urielmtzsa/r_project_1
```
```
docker run -it  -p 9999:9999  urielmtzsa/r_project_1
```
Y al abrir en tu navegador el host con el puerto [**0.0.0.0:9999**](http://0.0.0.0:9999) se mostrará la app en ejecución.

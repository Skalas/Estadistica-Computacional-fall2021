# Proyecto Respuesta Desastres

## Intergantes del equipo

| Nombre | CU | Mail | Usuario Gh |
| - | - | - | - | 
| Uriel Martínez Sánchez | 000202942 | umartin5@itam.mx | urielmtzsa |

*Una disculpa por hacerlo sólo profe, pregunté si me podía unir a algún equipo, pero creo que cuando lo hice ya todos estaban formados, jajaja.*

## Objetivo

Crear una solución práctica para las personas del estado de Nayarit en caso de un desastre natural para localizar el refugio más cercano a su disposición. Además de presentarles todas las posibles opciones de refugios con los que cuentan así como las caracterísiticas básicas de los mismos.

## Explicación breve de lo que se hizo

El repostiorio original en el que se encuentra toda la historia del desarrollo del proyecto se encuentra en el siguiente [**repositorio**](https://github.com/urielmtzsa/natural_disaster_project).

A partir de información de refugios de Nayarit dada en un excel, se crea un etl para extracción de información. Se realiza un documento que explica paso a paso lo hecho por el etl y un sencillo análisis exploratorio. Se realiza una app en shiny para encontrar el refugio más cercano dada una ubicación dada, además de proporcionar información del refugio al usuario. Adicionalmente, se crea una sencilla imagen en Docker para la ejecución del dashboard como respaldo al tema de "reproducibilidad".

## Dificultades

* Organización del proyecto, ya que se desarrollaron diversos scripts que se inter-conectan entre ellos.
* "Temor" a la reproducibilidad. Se crearon variables ajustables por si algo cambia en los directorios de trabajo locales. Adicional se cargó la imagen de la app a Docker como respaldo.
* Actualizar coordenadas al dar click en el mapa. Se investigó cómo hacerlo.
* Crear rutas de llegada al punto más cercano y establecer distancias y tiempo en función de la geografía real del lugar. Se investigó e implementó la paquería OSRM.
* Implementación en Shiny, ya que no se contaba con mucha experiencia en su uso.

## Conclusiones

1. Se desarrolló un ETL que convierte la información de un excel a un dataframe manejable.
2. Se logró crear un archivo .html que intenta explicar los pasos hechos al realizar el ETL.
3. Se desarrolló un dashboard en shiny funcional que le permite a los usuarios conocer el refugio más cercano a su ubicación. Además de proporcionarles información adicional del refugio como capacidad, contacto, servicios, distancia en km y minutos, etc.
4. Se logró cargar en DockerHub la implementación del dashboard para consumo "reproducible".
5. Finalmente, gracias al desarrollo de este trabajo se puede solucionar el "objetivo de negocio" para que una persona de Nayarit pueda llegar con facilidad al refugio más cercano a su ubicación (o el que prefiera) en caso de un desastre natural.


## Información detallada de la estructura del proyecto

### Organización de la carpeta

* El archivo **exec.R** ejecuta los archivos **proyecto1_etl.R** -> **proyecto_1_eda.Rmd** -> **app.R** en ese orden. Este archivo carga las librerías necesarias y ajusta el directorio de trabajo, sin embargo, cada archivo tiene las mismas líneas repetidas para carga de librerías y directorio de trabajo por si se requieren ejecutar de manera separada.
* El archivo **proyecto1_etl.R** realiza la conversión de la información de una archivo excel a un dataframe manejable. Si el archivo excel se localiza en un directorio diferente al dado por default (directorio donde se encuentren los archivos .R y .Rmd) o alguna variable del ETL cambia, en este archivo es donde se deben hacer las corrrecciones necesarias.
* El archivo **proyecto_1_eda.Rmd** muestra un resumen de los pasos hechos para crear el ETL y un pequeño análisis exploratorio. Este archivo es independiente a todos los demás, los cambios hechos en **proyecto1_etl.R** también se deben hacer en este. Este archivo arroja un html llamado **proyecto_1_eda.html**.
* El archivo **app.R** muestra el dashboard realizado para mostrar los refugios más cercanos para el usuario. Notar que este archivo depende del archivo **proyecto1_etl.R**, el cual se ejecuta automáticamente al ejecutar la app.

### Docker

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

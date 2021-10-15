# Estadística Computacional

## Tarea 1
Este directorio contiene la tarea #1 de los siguientes integrantes

|User | Nombre Completo|
|:---:|:---:|
|@vserranoc|Valeria|
|@jesusmb230795|Enrique Miranda|
|@yefovar|Yedam Fortiz|

### 1. Objetivo:

1. Un [Etl](https://en.wikipedia.org/wiki/Extract,_transform,_load) en R que tome los datos del formato en Excel y los transforme en un Data Frame que sea utilizable para análisis. (Ojo, el ETL tiene que asumir que puede pasar que le agreguen hojas al archivo de excel.)
2. Generar un motor sencillo que me indique el refugio más cercano a una coordenada dada.
3. Generar un dashboard que me ayude a identificar por localidad los refugios existentes.
4. Generar que el input de las coordenadas se maneje desde el dashboard.

### 2. Estructura del repositorio

```
├── README.md
├── data
│   ├── refugios_nayarit.xlsx
├── image
│   └── shiny_dashboard.png
├── notebook
│   └── etl.Rmd
├── renv
└── src
    ├── etl.R
    ├── nearest_location.R
    └── refugios_municipio_shiny.R
```

### 3. Reproducibilidad:

Para ejecutar el dashboard es necesario realizar lo siguiente:
1. Clonar el repositorio
2. Colocar la información referente a los refugios dentro de la carpeta con el siguiente nombre ``` data/refugios_nayarit.xlsx ```
3. Abrir el repositorio como un proyecto de rstudio (e.g. doble click sobre equipo10.Rproj) y definir la raiz del repositorio como directorio activo
4. Instalar el paquete de renv. ```install.packages("renv")```
5. Se utilizó un ambiente de R para poder replicar los resultados, para ello es necesario tener como directorio activo este repositorio y ejecutar ```renv::restore()```
6. Ejecutar la aplicación que se encuentra en la liga
``` src/refugios_municipio_shiny.R ```
7. La aplicación ejecutará el ETL, el cual se encarga de leer los refugios y transformarlos en una base para poder visualizar los resultados. Posteriormente se mostrará la aplicación la cual consiste en:
    * Búsqueda de refugios dado un municipio y su capacidad. Se anexa tanto el detalle por refugio con esas características como una referencia geoespacial.
    *  Búsqueda de los n refugios más cercanos dado una coordenada geoespacial. Se anexa tanto el detalle por refugio con esas características como una referencia geoespacial.
8. En caso de actualización de datos, es necesario detener la aplicación y volver a ejecutarla, no utilizar reload app.

### 4. Entregable
Se anexa imagen del Dashboard en shiny con los refugios encontrados por municipio y los refugios más cercanos dado una corrdenada geoespacial.

<img src="https://github.com/yefovar/Estadistica-Computacional-fall2021/blob/main/proyectos/RespuestaDesastre/equipo10/image/shiny_dashboard.png">





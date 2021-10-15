






                                [ Read 6 lines ]
^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell
Maestria Ciencia de Datos
Yedam
Zoom
 yedam@MacBook-Pro-de-Yedam  ~/Documents  cd Maestria\ Ciencia\ de\ Datos/
 yedam@MacBook-Pro-de-Yedam  ~/Documents/Maestria Ciencia de Datos  ls
Calificaciones.xlsx Estancia            Propedeutico        Tercer Semestre
Documentos          Primer Semestre     Segundo Semestre    Tesis
 yedam@MacBook-Pro-de-Yedam  ~/Documents/Maestria Ciencia de Datos  cd Tercer\ Semestre
 yedam@MacBook-Pro-de-Yedam  ~/Documents/Maestria Ciencia de Datos/Tercer Semestre  ls
Baja de materias.pdf               brain-theory-2021
Estadistica-Computacional-fall2021 braintheory
ITAM_MCC                           estcomp_proyecto1
Teoria del cerebro
 yedam@MacBook-Pro-de-Yedam  ~/Documents/Maestria Ciencia de Datos/Tercer Semestre cd estcomp_proyecto1
 yedam@MacBook-Pro-de-Yedam  ~/Documents/Maestria Ciencia de Datos/Tercer Semestre/estcomp_proyecto1   main ±  ls
README.md               image                   renv.lock
data                    notebook                src
estcomp_proyecto1.Rproj renv
  GNU nano 2.0.6              File: README.md

---
output:
  html_document: default
  pdf_document: default
---
# Estadística Computacional

## Tarea 1
Este directorio contiene la tarea #1 de los siguientes integrantes

|User | Nombre Completo|
|:---:|:---:|
|@vserranoc|Valeria|
|@jesusmb230795|Enrique Miranda|
|@yefovar|Yedam Fortiz|

### 1. Objetivo:

1. Un [Etl](https://en.wikipedia.org/wiki/Extract,_transform,_load) en R que to$
2. Generar un motor sencillo que me indique el refugio más cercano a una coorde$
                               [ Read 59 lines ]
^G Get Help  ^O WriteOut  ^R Read File ^Y Prev Page ^K Cut Text  ^C Cur Pos
^X Exit      ^J Justify   ^W Where Is  ^V Next Page ^U UnCut Text^T To Spell
  GNU nano 2.0.6                 File: README.md

---
output:
  html_document: default
  pdf_document: default
---
# Estadística Computacional

## Tarea 1
Este directorio contiene la tarea #1 de los siguientes integrantes

|User | Nombre Completo|
|:---:|:---:|
|@vserranoc|Valeria|
|@jesusmb230795|Enrique Miranda|
|@yefovar|Yedam Fortiz|

### 1. Objetivo:

1. Un [Etl](https://en.wikipedia.org/wiki/Extract,_transform,_load) en R que tome los d$
2. Generar un motor sencillo que me indique el refugio más cercano a una coordenada dad$
3. Generar un dashboard que me ayude a identificar por localidad los refugios existente$

^G Get Help   ^O WriteOut   ^R Read File  ^Y Prev Page  ^K Cut Text   ^C Cur Pos
^X Exit       ^J Justify    ^W Where Is   ^V Next Page  ^U UnCut Text ^T To Spell
  GNU nano 2.0.6                                                       File: README.md

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
3. Abrir el repositorio como un proyecto de rstudio (e.g. doble click sobre estcomp_proyecto1.Rproj)
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

<img src="https://github.com/yefovar/estcomp_proyecto1/blob/main/image/shiny_dashboard.png">





<p align = "center">
    <img src="images/logo_itam.png" width="300" height="110" />

## <p align = "center"> Maestría en Ciencia de Datos

## <p align = "center"> Estadística Computacional (_DS Programming_)   (Otoño 2021)

---

# Proyecto Respuesta Desastres  
**Integrantes del equipo**  

| Nombre                          |     CU   | Mail             | Usuario Gh                                    |
| :-----------------------------: | :------: | :--------------: | :-------------------------------------------: |
| Carlos Roman Lopez Sierra       | 197911   | clopezsi@itam.mx	| [Carlosrlpzi](https://github.com/Carlosrlpzi) |
| Edgar Bazo Pérez                | 000000   | ebazoper@itam.mx | [EddOselotl](https://github.com/EddOselotl)   |
| Uriel Abraham Rangel Díaz       | 193921   | urangeld@itam.mx | [urieluard](https://github.com/urieluard)     |
| José Luis Roberto Zárate Cortés | 183347   | jzaratec@itam.mx | [jlrzarcor](https://github.com/jlrzarcor)     |

---
---

## Tabla de contenido  :floppy_disk:

1. [Acerca de este proyecto](https://github.com/jlrzarcor/ITAM-ecomp2021-Ramis-prjct1#explicaci%C3%B3n-breve-de-lo-que-se-hizo)
2. [Estructura básica del proyecto](https://github.com/jlrzarcor/)
3. [Sobre nuestro *Data Pipeline*](https://github.com/jlrzarcor/ITAM-dpa2021#sobre-nuestro-data-pipeline--microscope)
4. [Instrucciones para correr este proyecto](https://github.com/jlrzarcor/ITAM-dpa2021#sobre-nuestro-data-pipeline--microscope)

---
## Explicación breve de lo que se hizo

Para este proyecto se creó una interfaz gráfica, donde las personas afectadas por huracán en el estado de Nayarit pueden localizar el refugio más cercano a su posición. Esta información la pueden visualizar en un mapa del estado mostrando la información de los siete refugios más cercanos a la ubicación del interesado.

Para ello se realizó un pipeline dividido en los siguientes pasos:

+ Extracción

+ Limpieza

+ Procesamiento (Motor)

+ Visualización

---
   

## Estructura básica del proyecto  :file_folder:

```
├── README.md              <- The top-level README for developers using this project.
│
│
├── data                   <- Data base with all the refugees in Nayarit
│   └── refugios_nayarit.xlsx  
│                          
├── notebooks              <- Rmd notebooks
│   ├── refugios_EDA_EBP.Rmd
│   └── refugios_nb.Rmd
│
├── images                 <- Contains images used in the repository.
│   └──logo_itam.png 
│
│                          
├── map_refugios           <- Shiny's app files. 
│   ├── app.R
│   └── Global.R                         
│
│                          
│
├── .gitignore             <- Avoids uploading data, credentials, outputs, system files etc.
│
│
│
├── imports_initial.sh     <- Shell file for getting Shiny's requirements. 
│
│
│    
├── references             <- If any (not available in the current deliver).
│                          
│
├── results                <- If any (not available in the current deliver).
│                          
│                         
└── src                    <- Source code for use in this project.
    │
    │
    ├── utils              <- Functions used across the project.
    │
    │
    └── etl                <- Scripts to transform data from raw to intermediate.
 
```
   
    
    
---  
 
## Sobre nuestro *Data Pipeline*

### Extracción

Esta se realizó con la librería `openxlsx`, la cual permite interactuar facilmente con archivos excel con diferentes caracteristicas, como número de hojas y rangos de celdas.

### Limpieza

Para esto utilizamos el paquete `tidyverse`, el cual te permite llevar a cado diferentes acciones que resumen la mayor parte de las actividades que tiene que realizar un Data Scientist.

### Procesamiento

En este paso del pipeline utilizamos la librería `geosphere`. En esta podemos encontrar la función `dsitHaversine`, la cual calcula la distancia entre dos puntos en una geometría esferica (aquí asumimos una esfericidad perfecta de la tierra).

### Visualización

Por la necesidad del tipo de proyecto utilizamos `Shiny`, esto nos permite tener una interfaz gráfica interactiva con la cual los interesados en encontrar un refugio lo pudieran hacer de manera sencilla.
    
--- 
### Instrucciones para correr este proyecto

1. Clonar repositorio
2. Abrir una sesión de R y crear un nuevo Rproject (file > New Project)
3. Navegar en el equipo para que el Rproject se ubique en la carpeta donde se clonó el repositorio
4. Verificar que esté habilitada la función: "Use renv with this project" en "Project Options" del  menú "Tools"
5. Verificar que se tenga instalado el paquete "renv", en caso contrario instalarlo con: install.packages("renv")
6. Ejecutar en la línea de comandos: renv::hydrate(), renv::activate() y renv::restore()
7. Abrir una terminal de linux (puede ser wsl) y posicionarse en la raíz del proyecto. Ejecutar el siguiente comando:
> bash imports_initial.sh
8. Ejecutar secuencialmente los comandos del archivo main_refugios.R

Esto abrirá la aplicación de shiny que contiene el mapa interactivo con los refugios señalados en el mapa (globos de color azul los refugios, de color verde los cercanos y en rojo la posición seleccionado como actual o la actual si se utiliza la funcionalidad de localizarme en un browser.)

Utilización de la app:
Para ir la ubicación actual del interesado se tiene que hacer clic en el bóton que se encuentra en la parte superior que tiene la leyenda "Open in Browser". Ahí se tiene que dar clic en la flecha que se encuentra debajo del los signos más (+) y meneos (-), de esta manera esará en la posición actual del interesado y marcará en color verde los 7 refugios más cercanos a esa posición.

Haciendo click sobre algún refugio mostrará en casilla "pop-up" la dirección y el teléfono del refugio.
Se puede dar click en algún lugar del mapa y se actualizarán los globos de color verde que indican la distancia más cercana al punto seleccionado
        
---   

### Dificultades
    
Las principales dificultades se presentaron en los siguientes rubros:

    
Base de datos: La base de datos presenta algunas inconsitencias, lo cual es comprensible ya que se entiende que fue recabada en un momento de emergencia y sin mucha oportunidad de hacer un proceso controlado para la información. Dado que la información no se puede validar directamente con negocio.  
    
Imputación: Dado que del EDA realizado se vió que no es un gran porcentaje de la información la que presenta inconsitencia se optó por no incluir estos registros ya que podría ser contraprodcente dar información erronea a personas en situación de emergencia.
    
Transformación de variables: Las variables de importancia para la aplicación son latitud y longitud, en estas había una gran cantidad de formatos en los que se cargaron los datos, esto representó un gran reto para conservar la información relevante sin perder datos importantes. En los casos donde hubo dudas razonables en las que no se trataba de formato se optó por reportar estos registros para su verificación. (más detalles se pueden ver en los Rmd de este repositorio)

Aplicación de Shiny: adaptarse a la lógica de programación de Shiny, crear tablas en Shiny y uso de barras de navegación, uso de variables globales comprender algunos conceptos de js, etc.

Descargar el archivo de forma programática. Al ser un drive de Google, al descargar el archivo con curl el archivo está corrupto.
---
 
### Conclusiones
 
En el desarrollo de este trabajo utilizamos diferentes herramientas que usa un científico de datos cotidianamente, cómo lo son: R, RStudio, Shell Scripting y Shiny. Esto nos permitió conocer la interacción de dichas herramientas aplicadas a un problema real y entender el flujo de trabajo de este tipo de proyectos. Esto nos dio una gran perspectiva a la que se enfrenta un profesional de esta disciplina y de los medios de solución con los que cuenta.
 
Conocer estas tecnologías nos permiten cómo científicos de datos crear herramientas poderosas que permiten ayudar a personas en situación de emergencia y con ello darnos cuenta del enorme potencial que tienen estas en situaciones tan delicadas cómo lo es un huracán. 


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
| Uriel Abraham Rangel Díaz       | 000000   | urangeld@itam.mx | [urieluard](https://github.com/urieluard)     |
| José Luis Roberto Zárate Cortés | 183347   | jzaratec@itam.mx | [jlrzarcor](https://github.com/jlrzarcor)     |

---

Nuestro tgrabajo se desarrolló en un  repositorio especial para evitar sobre cargar el repositorio de la materia,
para lo cual se deberá clonar el repositorio en la siguiente liga y seguir las instrucciones (mismas que están en
el repositorio):

Liga a repo: [Ramis-prjct1](https://github.com/jlrzarcor/ITAM-ecomp2021-Ramis-prjct1)

---

--- 
### Instrucciones para correr este proyecto

1. Clonar repositorio
2. Abrir una sesión de R en la ubicación donde se clonó el repositorio
3. Verificar que esté habilitada la función: "Use renv with this project" en "Project Options" del  menú "Tools"
4. Verificar que se tenga instalado el paquete "renv", en caso contrario instalarlo con: install.packages("renv")
5. Ejecutar en la línea de comandos: renv::activate()
6. Correr el archivo .R que se encuentra en la ruta: /src/etl/etl.R
7. Correr el archivo .R que se encuentra en la ruta: /map_refugios/global.R
8. Correr el archivo .R que se encuentra en la ruta: /map_refugios/app.R
9. Dar click al botón "RunApp". Esto abrirá la aplicación de shiny que contiene el mapa interactivo con los refugios señalados en el mapa (globos de color rojo)

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
    
---
 
### Conclusiones
 
En el desarrollo de este trabajo utilizamos diferentes herramientas que usa un científico de datos cotidianamente, cómo lo son: R, RStudio, Shell Scripting y Shiny. Esto nos permitió conocer la interacción de dichas herramientas aplicadas a un problema real y entender el flujo de trabajo de este tipo de proyectos. Esto nos dio una gran perspectiva a la que se enfrenta un profesional de esta disciplina y de los medios de solución con los que cuenta.
 
Conocer estas tecnologías nos permiten cómo científicos de datos crear herramientas poderosas que permiten ayudar a personas en situación de emergencia y con ello darnos cuenta del enorme potencial que tienen estas en situaciones tan delicadas cómo lo es un huracán. 

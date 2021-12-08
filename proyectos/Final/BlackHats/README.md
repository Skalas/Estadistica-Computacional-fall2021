# Equipo: Black Hats

## **Título del proyecto**: Algoritmo BFGS para regresión logística. 

### Integrantes

|       User        |              Nombre               | Clave única |
| :---------------: | :-------------------------------: | ----------- |
| @nelsonalejandrov |    Nelson Alejandro Gil Vargas    | 203058      |
|      @Monfiz      | Alejandro Alfredo Muñoz Gutiérrez | 203021      |
|     @pautrejo     |      Paulina Hernández Trejo      | 149131      |
|    @marcoel21     |    Marco Antonio Ramos Juárez     | 142244      |

### **Objetivo del proyecto**
Este proyecto tiene como finalidad desarrollar un producto de datos completo para el modelado de datos financieros. Particularmente, nos basamos en los datos de fondos de inversión de [INVEX]( https://invex.com/Personas/Inversiones/Fondos-de-inversion). La complejidad de esto radica en que los datos no se encuentran limpios en un archivo csv, listos para ser explotados. En realidad, los datos se encuentran en documentos pdf que se cargan a la página de INVEX de forma periódica por lo que es necesario hacer un scrappeo en Bash para obtener nuestra base de datos. Posteriormente, estos datos se agregarán a una base de datos construida en PostgreSQL y esta base alimentará a un modelo en Python. El entrenamiento del modelo y las predicciones podrán ser visualizadas por medio de una API construida con Flask. Para concluir, todo es proyecto  es totalmente reproducible con el uso de un contenedor de Docker que nos permite empaquetar nuestro proyecto y que otros usuarios tengan acceso a él sin problemas de compatibilidad.



## Archivos:

Puedes encontrar los siguientes archivos en esta carpeta: 

* **app.py:** aplicación API de python con flask  (dentro de carpeta **scripts**)

* **modelo.py**: script de python que corre el modelo de Random forest (dentro de carpeta **scripts**)

* **init_sql.sql:** script que construye la base de datos  (dentro de carpeta **scripts**)
* **Dockerfile:** Script que crea la imagen de Docker 
* **docker-compose:** script que corre la imagen del proyecto, postgres y pgadmin que te permite interactuar con la base de datos
* **total_carteras_sem.sh:** script que hace el scrappeo de los datos, los limpia y escribe un txt  (dentro de carpeta **scripts**)
* **composicion_carteras_sem.sh:** script que hace el scrappeo de los datos, los limpia y escribe un txt  (dentro de carpeta **scripts**)



##  Tecnologías utilizadas

* PostgreSQL
* BASH
* Python
* Docker

## Librerías y Paquetes Utilizados Python

- Flask

- Sklearn

- Numpy

- Pandas

  

## Referencias 

* [Fondos INVEX]( https://invex.com/Personas/Inversiones/Fondos-de-inversion)
* [Docker copy](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
* [PostgreSQL y PgAdmin en docker-compose](https://www.youtube.com/watch?v=uKlRp6CqpDg&t=679s)


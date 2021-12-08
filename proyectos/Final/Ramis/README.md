<p align = "center">
    <img src="images/logo_itam.png" width="300" height="110" />

## <p align = "center"> Maestría en Ciencia de Datos

## <p align = "center"> Estadística Computacional (_DS Programming_)   (Otoño 2021)

---

# Proyecto: Creación de un Producto de Datos
:busts_in_silhouette:  **Integrantes del equipo** git 

| Nombre                          |     CU   | Mail             | Usuario Gh                                    |
| :-----------------------------: | :------: | :--------------: | :-------------------------------------------: |
| Carlos Roman Lopez Sierra       | 197911   | clopezsi@itam.mx | [Carlosrlpzi](https://github.com/Carlosrlpzi) |
| Edgar Bazo Pérez                | 172061   | ebazoper@itam.mx | [EddOselotl](https://github.com/EddOselotl)   |
| Uriel Abraham Rangel Díaz       | 193921   | urangeld@itam.mx | [urieluard](https://github.com/urieluard)     |
| José Luis Roberto Zárate Cortés | 183347   | jzaratec@itam.mx | [jlrzarcor](https://github.com/jlrzarcor)     |

---
## :chart_with_upwards_trend:   Estadísticas del repositorio   :chart_with_downwards_trend:

👀  ![Watching](https://img.shields.io/badge/Watching-3-blue/?logo=GitHub&style=social)
🌟  ![Stars](https://img.shields.io/badge/Stars-4-blue/?logo=GitHub&style=social)
🔌  ![fork](https://img.shields.io/badge/Fork-2-blue/?logo=GitHub&style=social)
👥  ![contributors](https://img.shields.io/badge/Contributors-4-blue/?logo=GitHub&style=social)

---

## Tabla de contenido  :bookmark_tabs:

1. [Objetivo](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#objetivo--dart)
2. [Herramientas utilizadas](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#herramientas-utilizadas--wrench)
3. [Estructura del Repositorio](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#estructura-del-repositorio--open_file_folder)
4. [El Producto de Datos](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#el-producto-de-datos--computer)
    - 4.1 [Problema que resuelve](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#problema-que-resuelve--grey_question)
    - 4.2 [Especificaciones](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#especificaciones--clipboard)
    - 4.3 [Funcionamiento](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#funcionamiento--video_game)
    - 4.4 [Resultados](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#resultados--bar_chart)
5. [¿Cómo correr el proyecto?](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#c%C3%B3mo-correr-el-proyecto)

---

## Objetivo  :dart:
El objetivo del proyecto es implementar y empaquetar un **Producto de Datos** completo, para que se pongan en práctica las herramientas revisadas durante el curso de Estadística Computacional.

## Herramientas utilizadas  :wrench:
+ [Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html "Bash"): Lo utilizamos para hacer la descarga y limpieza de los datos utilizados.
+ [Python](https://docs.python.org/3/): Es el lenguaje de programación que se utilizó para implementar un modelo de clasificación binaria. 
+ [SQL -PostgreSQL](https://www.postgresql.org/docs/9.3/sql.html): Manejador de base de datos empleada para el almacenamiento y procesamiento de la información recolectada.
+ [APIs -Flask](https://flask.palletsprojects.com/en/2.0.x/): Interfase elegida para hacer las interacciones entre los usuarios y el producto de datos.
+ [Docker](https://docs.docker.com/): Herramienta para la creación de contenedores de Linux que se utiliza para empaquetar todo el producto de datos y pueda ser utilizado en cualquier equipo de cómputo que cumpla con los [requerimientos](falta).

[Regresar](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#tabla-de-contenido--bookmark_tabs)

## Estructura del Repositorio  :open_file_folder:

```
├── README.md          <- The top-level README for developers using this project.
│
├── images             <- Contains images used in the repository.
|
├── notebooks          
│   └── eda            <- Jupyter notebooks for EDA
|
├── references         <- Consulted references to document this proyect
|
├── results            <- If so, some relevant results
|
├── sql                <- Contains scripts used to deploy RDS db.
│
├── requirements.txt   <- The requirements file.
│
├── .gitignore         <- Avoids uploading data, credentials, outputs, system files etc.
│
└── src                <- Source code for use in this project.
    │
    ├── __init__.py    <- Makes src a Python module.
    │
    │
    ├── api            <- Contains Python modules used for app deplyment.
    │
    │
    ├── dashboard      <- Contains Python modules used for dashboard deplyment.
    │
    │
    ├── utils          <- Functions used across the project.
    │
    │
    ├── etl            <- Scripts to transform data from raw to intermediate.
    │
    │
    └── pipeline       <- Functions used for the pipeline.  
```

[Regresar](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#tabla-de-contenido--bookmark_tabs)
	
## El Producto de Datos  :computer:

Se pide un producto de datos completo, esto es, que tenga todos los componentes necesarios para que sea un análisis vivo y creciente de la información que va llegando al modelo de aprendizaje de máquina (modelo en adelante) y se logre cumplir con la finalidad para que fue diseñado.

### Problema que resuelve  :grey_question:
Es de nuestro interés (didáctico) generar un producto de datos que nos permita tener un flujo de trabajo implementado de manera completa en una aplicación. Con esta aplicación le daremos servicio (hipotéticamente) a una empresa que se dedica a la aseguranza de vehículos tipo [caravana](https://helloauto.com/glosario/caravana) y requiere saber **¿Cuáles personas, de una cartera de clientes que han adquirido este tipo de vehículos, estarían interesados en adquirir un seguro?**.

### Especificaciones  :clipboard:
Se solicita que la aplicación contenga los siguientes requisitos:
 + **Base de Datos de soporte:** Los datos deben de guardarse en un postgreSQL, esto para replicar la necesidad de motores externos de bases de datos en la vida real.
 + **Ingesta inicial.** La primer insersión de los datos a su base de datos debe de ser a través de Bash.
 + **Modelo como Servicio Web.** La API debe tener un modelo corriendo a manera de servicio.
 + **Reentrenamiento del Modelo .** Pasado un tiempo y con suficientes datos nuevos, usualmente se busca un reentrenamiento del modelo, por lo cual su API debe de ser capaz de hacerlo mediante una solicitud.
 + **Ambiente totalmente reproducible.** La API debe estar empaquetada por completo para que pueda correr sin ningún problema en cualquier computadora.
 + **Captura de resultados del Modelo.** Se busca entender el rendimiento y precisión del modelo, por ello es necasio desplegar sus resultados de desempeño, tal que el equipo de ciencia de datos pueda entender qué tan bien o mal está respondiendo.

### Funcionamiento  :video_game:
La información con la que se cuenta es una base de datos que proviene de la compañía _Sentient Machine Research_ y esta disponible en la página de [kaggle](https://www.kaggle.com/uciml/caravan-insurance-challenge). Este _Data Set_ cuenta con aproximadamente 10,000 observaciones de 86 variables. Las variables que se tienen son de tipo socio-demográficas, de propietarios de vehículos tipo caravana, así como de estadísticas de seguros. cada observación corresponde a la de un código postal (granularidad).

Con esta base de datos (**ingesta inicial**) se entrena un modelo de regresión logística mediante el paquete de _Sklearn_ de _Python_ y se calculan sus métricas de desempeño con un set de validación que también es parte del _Data Set_ mencionado. Para poder hacer predicciones de nuevos registros, se deberán ingresar los campos que se determinaron en el proceso de modelado a través de una interfase creada en _Flask_ (una API). Para cada nueva observación que se ingrese mediante la API se hará la predicción con el modelo que resultó del entrenamiento. A esta interfase de la API le denominamos predicciones _On Demand_. Esta parte de la solución se utilizará por la empresa para identificar potenciales compradores de seguros y realizar campañas y/o estrategias de venta, con el fin de incrementar la venta de este tipo de seguros.

Por separado, existirá otra API (también creada en _Flask_) que se utilizará para cargar nuevos registros a la base de datos de entrenamiento, la cual tendrá dos opciones: **Almacenar** y **Entrenar**. 

 + Con la primera opción (Almacenar) solo se almacenan nuevos registros en la Base de Datos, pero el modelo sigue siendo el mismo, el entrenado con la ingesta inicial. A este proceso le denominamos **ingesta consecutiva**.

 + Con la segunda (Entrenar), se ejecuta nuevamente el proceso de entrenamiento del modelo, utilizando los datos nuevos que se hayan almacenado en los diferentes periodos o ingestas consecutivas que se hayan realizado.

[Regresar](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#tabla-de-contenido--bookmark_tabs)	

### Resultados  :bar_chart:

Lo que esperamos observar cuando se logre ejecutar este proyecto es lo siguiente:

+ API para el modelo _On Demand_

<p align = "center">
    <img src="images/API_1.png" width="300" height="110" />

+ API para el proceso de ingesta consecutiva y reentrenamieto:

<p align = "center">
    <img src="images/API_2.png" width="300" height="110" />

[Regresar](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#tabla-de-contenido--bookmark_tabs)
	
## ¿Cómo correr el proyecto? 

### Prerrequisitos  :computer:
Se necesita un equipo de computo con acceso a internet, un sistema operativo Linux y Docker instalado.

### Ejecución  :clapper:
	1. clonar este repositorio en la computadora local (en el directoro de su preferencia)
	2. Abrir una terminal CLI y colocarse en la raíz del repositorio clonado en el paso anterior
	3. Ejecutar comando: <docker-compose up --build> con lo que se construye nuestra imagen de Docker
	4. Ejecutar comando: <docker exec -it web_ramis bash> con lo que se accede al contenedor
	5. En la terminal que ya es del contenedor abierto posicionarse en la carpeta con el siguiente nombre: jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct
	6. Activar el ambiente virtual de conda: _conda activate est_comp_
	7. Exportar la variable de ambiente: <export PYTHONPATH=$PWD>
	8. Correr el comando de Bash: <bash data_process.sh> con lo que se descarga la base de datos de Caravanas y se hace la limpieza. La salida se persiste en un volumen creado en local al que se puede acceder desde el contenedor
	9. Ejecutar el script de python: <python src/utils/pdDF_to_SQL.py> que hace la lectura del archivo procesado por Bash y lo coloca en una tabla de PostgreSQL
	Nota: Para verivicar la creación de esta tabla, ejecutar: <psql -U postgres -h db -d postgres> para ingresar al servidor de psql y dentro de este explorar la tabla creada ("variables")
	10. Abrir una terminal de python y ejecutar: <from src.utils import utils> y <modelo, precision, recall = modelado()> con esto se hace el primer modelo que corresponde a la ingesta inicial y con el cual ya se pueden hacer predicciones desde la API. El modelo se guarda en un archivo binario (.pkl)
	11. Colocarse en un navegador y accesar a la dirección: <http://0.0.0.0:8080/> Esto desplegará los primeros 10 registros de la base de datos (informativo)
	
	Para realizar una predicción:
	Colocarse en una terminal CLI de su máquina local y ejecutar un comando de _curl_ como el siguiente ejemplo:
	
	curl -X POST -H "Content-Type: application/json" -d '{"predecir":{"mopllaag":1, "mink123m":2, "ppersaut":3, "pwaoreg":4,"pbrand":5,"aplezier":6,"afiets":7}}' 0.0.0.0:8080/users
	
	Nota: Los valores de cada llave corresponden a los valores que tendría una nueva observación de la cual queremos hacer su predicción

[Regresar](https://github.com/jlrzarcor/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct#tabla-de-contenido--bookmark_tabs)

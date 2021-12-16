# Proyecto Final 
## Integrantes 
* Jorge Garcia Durante. CU: 202945
* Monica Garcia. CU: 203145
* Arturo Soberon Cedillo. CU: 130524
* Rodrigo Juarez. CU: 145804

## Overview

El siguiente proyecto consite en la creación de un aplicación cuyo objetivo es predecir el ingreso estimado de una persona de acurerdo a sus características socioeconómicas y sociodemográficas. Para ello se utilizaron herramientas de software importantes como lo son:

* Bash
* Postgres SQL
* Docker y docker compose
* Python flask
* Python sklearn

## Estructura de la app

Para su funcionamiento la estruructura de la app es la siguiente:

* Docker_compose.yml: este archivo contiene las instrucciones de inicio y empaquetado dentro de un contenedor de nuestra aplicación.
* Dockerfile: este archivo nos ayuda a ejecutar los requerimientos necesarios para el funcionamiento de nuestra aplicación
* app.py: este archivo es el que nos permite la interacción entre los usuarios y las predicciones del modelo, así mismo es la que nos permite trabajar con la base de datos.
* init.sql: durante el proceo de inicialización de nuestra aplicación este archivo es copiado dentro de nuestro ambiente y contiene las inttrucciones de las tablas a crear para el correcto funcionamiento de la aplicación
* df.csv: este archivo contiene los datos de entrenamiento del modelo inicial y es copiado a nuestro ambiente durante la inicialización de la app. 

## Inicialización 

Para inicializar la app es necesario que se tenga *Docker* y *Docker compose* instaladao. Para poder ejecutar la app se requiere abrir una terminal desde la carpeta donde este guardad la aplicación es decir sobre la ruta ../app. Una vez teniendo esto se ejecuta el siguiente código:

```
docker-compose up --build
```

Este código permitirá instalar todo lo necesario dentro de un contenedor para el correcto funcionamiento de la aplicación. Cuando se inicializa por piemera vez es posible que la aplicación intente hacer una conexión desde al archivo app.py sin que se haya terminado la ejecuión completa de la conexión a la base de datos, esto sucede porque las imagenes se crean desde antes. Concecuencia  de ello es que se mandará un error de conexión, para solucionar esto basta esperar a que se terminen de crear las imagenes y volver a ejecutar e código antes mencionado. Durante la inicialización se considera la creación de las imagenes de postrgres y nuestra aplicación así como la creación de la base de datos y la carga de los datos. Se crean entonces tres tablas que son:

* **train_table:** donde se almacenan los datos con lo que se entrena el modelo original
* **train_new:** tabla donde se almacenan nuevos datos que el usuario de la aplicación ingrese
* **train_res:** tabla dondde se almacenan los resultados de la perdicción

## Carga de los datos

La carga de los datos se hace a través de sql durante la inicialización de la app. Para lograr esto dentro del archivo docker-compose.yml en la parte de volumes se copia una carpeta llamada postrgres/csvs que debe contener el archivo con los datos necesarios para su carga. Finalemnte dentro del archivo init.sql se ejecuta el siguiente código:

```
COPY train_table (ingreso, internet, edad, hrs_trab, educacion, num_autos, num_compu, num_cuartos,seguro_med,mujer,resid) FROM '/var/lib/postgresql/csvs/df.csv' DELIMITER ',' CSV HEADER;
```

## Modelo

Se utilizó la encuesta [ENIGH 2020](https://www.inegi.org.mx/programas/enigh/nc/2020/#Tabulados) para crear un modelo **XGBoost** capaz de predecir el ingreso de las personas con base en sus características socioecónomicas y sociodemográficas. Se ocupó información de viviendas, población, ingresos y hogares a partir de la cual se armó un data set final. Las variables consideradas para el entrenamento del modelo son:

* **ingreso**. Representa el monto de ingreso de una persona.
* **internet**. Variable categorica que indica si se cuenta o no con internet.
* **edad**. Variable numérica que indica la edad de la persona.
* **hrs_trab**. Variable numérica que indica las horas de trabajo de una persona en un día.
* **educacion**. Variable categoria que indica por grupo el nivel escolar al que pertnence una persona. Valor 0 corresponde a las personas que no cuetan con educación o cuyo nivel escolar máximo es secundaria. Valor 1 corresponde a preparatoria. Valor 2 corresponde a que cuenta con escuela normal, técnica o profesional. Valor 3 corresponde a maestría y valor 4 a doctorado.
* **num_autos**. Variable numérica que hace referencia al número de autos con los que cuenta la persona.
* **num_compu**. Variable numérica que hace referencia al número de computadoras con las que cuenta una persona.
* **num_cuartos**. Variable numérica que hace referencia al número de cuartos con los que cuenta la casa donde vive la persona. Sólo cuenta cuartos para dormir y cocina.
* **seg_medico**. Variable categórica que hace referenica a si la persona cuenta con seguro médico o no.
* **mujer**. Variable categóriaca que hace referncia a si la persona es mujer o no.
* **resid**. Variable numérica que hace referencia al número de residentes en la casa donde vive la persona en cuestión.

## Funcionamiento de la aplicación

Si se cuenta con linux o mac dentro de la terminal se pueden ejecutra los siguientes códigos basados en **curl**. Si cuentas con windows puede ser neceario que recurras a pogramas como **postman** o **insomnia** para que se puedan enviar los request. 

**Presentación del los autores:**

```
curl --request GET --url http://127.0.0.1:4000/presentacion/
```

**Insertar datos:**

```
curl --request POST \
  --url http://127.0.0.1:4000/new_data/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"ingreso":10000,
		"internet":1,
		"edad":28,
		"hrs_trab":0,
		"educacion":2,
		"num_autos":2,
		"num_compu":2,
		"num_cuartos":5,
		"seguro_med":1,
		"mujer":0,
		"resid":3
	},


	{
		"ingreso":20000,
		"internet":1,
		"edad":35,
		"hrs_trab":4,
		"educacion":2,
		"num_autos":2,
		"num_compu":2,
		"num_cuartos":10,
		"seguro_med":1,
		"mujer":0,
		"resid":3
	}]'

```

**Consulta de datos:**

Para la consulta de datos debes indicar el rango de id's que deseas consultar y se regresara una respuesta con el detalle. 

```
curl --request GET \
  --url http://127.0.0.1:4000/new_data/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"id_ini":10,
		"id_fin":12
	}]'
```
**Borrar datos:**

Para borrar datos se debe indicar el id del registro que se desea borrar. Puedes saber este id haciendo uso de la consulta de datos. Por reglas de seguridad de la información sólo se considera el borrado registro a registro.

```
curl --request DELETE --url 'http://127.0.0.1:4000/new_data/?id=9'
```

**Actualizar datos:**

Para la actualización de datos es importante que indiques el id del registro que se desea actualizar. Aunque no se cambien todas las variables debes considerar ingresarlas y sólo cambiar al valor de las que se deseen actualizar. 

```
curl --request PATCH \
  --url http://127.0.0.1:4000/new_data/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"id":14,
		"ingreso":1000,
		"internet":1,
		"edad":28,
		"hrs_trab":8,
		"educacion":2,
		"num_autos":2,
		"num_compu":2,
		"num_cuartos":7,
		"seguro_med":1,
		"mujer":1,
		"resid":3

	}]'
```

## Hacer una predicción

**Realizar una predicción:**

Cuando se realiza una o más predicciones los datos usados para la predicción y el resultado de esta son almacenados en una tabla llamada train_res. El siguiente ejemplo predece el ingreso de un hombre vs una mujer en donde el resto de características son iguales: 

```
 curl --request POST \
  --url http://127.0.0.1:4000/predict/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"internet":0,
		"edad":34,
		"hrs_trab":11.5,
		"educacion":3,
		"num_autos":2,
		"num_compu":2,
		"num_cuartos":4,
		"seguro_med":4,
		"mujer":1,
		"resid":5	
},	
{
		"internet":0,
		"edad":34,
		"hrs_trab":11.5,
		"educacion":3,
		"num_autos":2,
		"num_compu":2,
		"num_cuartos":4,
		"seguro_med":4,
		"mujer":0,
		"resid":5	
}]'
```

**Reentrenar el modelo:**

Para reentrenar el modelo sólo se hace una petición a través de un método get. El reentrenamiento va a considerar los datos nuevos que se han ingresado más los datos que fueron utilizados para entrenar la versión original del modelo:

```
curl --request GET \
  --url http://127.0.0.1:4000/recalibrate/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"Recalibrar":1,

	}]'
```
**Regresar al modelo original:**

Para regresar al modelo original la aplicación utilizará los datos que fueron cargados desde la inicialización de la app y se hace a través de un método GET:

```
curl --request GET \
  --url http://127.0.0.1:4000/reset/ \
  --header 'Content-Type: application/json' \
  --data '[
	{
		"Modelo_orig":1
	}]'
```

## Consideraciones

* El modelo trabaja con tres tablas que fueron creadas desde el inicio que son train_table que contiene la data original, train_new que almacena los nuevos datos y train_res que guarda los resultados de las predicciones.
* Desde la API sólo se pueden hacer modificaciones a la tabla train_new mediante las peticiones descritas anteriormente.
* La eliminación de datos se hace uno a uno, pensando en temas de seguridad de la información. Lo mismo se considera en la actualización.
* Los datos originales del modelo entrenado están en una tabla que en ningún request se actualiza, sólo se consulta en todo caso.
* No se tuvieron problemas para correr la aplicación en diferentes sistemas operativos, sin embargo en un sistema operativos windows el manejo es más complejo. Una posible solución sería instalar una imagen de Ubuntu para usar la terminal. 

## Referencias 

* Miguel Escalante, sesión de dudas y clases. Estadistica computacional, curos 2021. 
* [Cómo hacer una aplicación en FLASK y colocarla en un entorno de desarrollo con Gunicorn y Docker.](https://peznuss.medium.com/c%C3%B3mo-hacer-una-aplicaci%C3%B3n-en-flask-y-colocarla-en-un-entorno-de-desarrollo-con-gunicorn-y-docker-52820b5af09b)
* [How to Dockerize an Existing Flask Application](https://towardsdatascience.com/how-to-dockerize-an-existing-flask-application-115408463e1c)
* [Postgres Image](https://hub.docker.com/_/postgres)
* [Postgres.org](https://www.postgresql.org/)
* [Overview of Docker compose](https://docs.docker.com/compose/)
* [ENIGH 2020](https://www.inegi.org.mx/programas/enigh/nc/2020/#Tabulados)



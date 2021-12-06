# Proyecto Final: Estadística Computacional
### Integrantes

* Adrian Tame Jacobo, CU: 142235
* Miguel Calvo Valente, CU: 203129

### Resumen

Proyecto final de estadística computacional 2021. El proyecto involucra varias tecnologías importantes: 

* Bash
* PostgreSQL
* Docker
* Docker Compose
* Flask (para generar un API)
* Sklearn

### Instrucciones de inicialización

Para prender la base de datos, es importante correr dos diferentes comandos, primero, 

```bash
docker-compose up --build
```

Esto va a inicializar dos containers de Docker, el de PosgreSQL llamado `db_miguel_adrian`, y el del API, llamado `web_miguel_adrian`. 

**NOTA IMPORTANTE:** El comando de `depends on: db` del archivo `docker-compose.yml` hace que se espere el container de web a levantar la base de datos, pero **no la inicialización de ella en `localhost:5432`**. Por lo tanto, puede ser que haya una falla de levantar el container `web_miguel_adrian` cuando se corre este comando, pero, hay una opción de `restart: on-error: (10)`, lo que hace que se inicialize aunque tenga error el container de web, por lo tanto, **es recomendable deja este comando correr hasta ver el mensaje de que está abierta la aplicación web en `localhost:8080`**. 

Después de esto, para la carga inicial de los datos, se hace desde adentro del mismo docker. En el `Dockerfile` pedimos que se instalara `curl` para poder mandar datos a la aplicación ya corriendo, y por lo tanto, se hace la carga inicial corriendo:

```bash
docker exec web_miguel_adrian curl -X POST -H "Content-Type: application/json" -d @app/datos_json.txt 0.0.0.0:8080/users
```

Esto dejará el docker corriendo con la base entera de datos accesible. Además de esto, el folder de `datos` es persistente, por lo que solamente se tiene que correr la primera vez que se levanta la aplicación este comando de cargar los datos. 

**Otra Nota Importante:** Una de las personas trabajando en este proyecto estaba en Windows, y la otra en MacOS. Vimos comportamientos un poco extraños y no podíamos prender el Docker en Windows, **pero solamente cuando este se bajaba de git.** Empezamos a intercambiar `.zip`'s para lidiar con esto y funcionó. Por lo tanto, subimos aquí un zip también en el caso de que exista este problema. 

### Base de datos

Utilizamos la base de datos tomada de [este sitio en Kaggle](https://www.kaggle.com/fedesoriano/stroke-prediction-dataset). Es una base de datos cuyo propósito es hacer clasificación de si una persona va a tener un derrame cerebral o no, dependiendo de ciertas variables de su vida y cuerpo. Notamos que hay varios registros con valores `N/A`, y por lo tanto, se requirió limpieza en Bash para poder usar la base de datos. 

Además de esto, muchas de las variables eran categóricas de texto, entonces se utilizaron también herramientas de Bash para transformarlas a variables categóricas pero numéricas (e.g. `smoking` = 1, `never smoked` = 2, etc.)

**Relación de variables con los datos originales:**

* Para la variable de género, `Other, Female` = 0, y `Male` = 1. 
* Para la variable de si han estado casados, `Yes` = 1 y `No` = 0.
* Para la variable de rural o urbano, `Urban` = 1, y `Rural` = 0. 
* Para la variable de si ha fumado antes, `never smoked` = 0, `formerly smoked` = 1, `smokes` = 3 y `Unknown` = 4. 
* No utilizamos la variable de `working type`. 
* La variable a predecir es `stroke`, toma valores de 0 y 1, por lo tanto es un problema de clasificación lo que tenemos. 

### Procedimiento de limpieza de datos

El archivo inicial de la base es ` app/healthcare-dataset-stroke-data.csv `, y através de el script de `limpieza.sh`, lo trabajamos con `awk`, `cut` y `sed` para tener la base de datos limpia. Después de esto, utilizamos la aplicación de línea de comando `jq` para pasar estos datos de `.csv` a `.txt`, *pero con el formato de json* (esto se hace en la línea 9 del `Dockerfile` ). Esto es importante para la carga de los datos a la base, ya que lo hacemos con `curl` especificando que son *json*. 

### Guardada local de modelos

En lo que nos decidimos dedicar y pasar el tiempo fuera de los requisitos base del proyexto fue en implementar un sistema robusto para guardar y accesar los modelos que se entrenan con la base de datos. 

### Puntos de acceso con el API 

Tenemos una lista (no exhaustiva) de cosas que se pueden hacer con nuestra aplicación. 

```bash
# Ejemplo de entrenar modelo pasándole la grid
curl -X GET -H "Content-Type: application/json"\
     -d '{"n_estimators": [60, 80], "max_features": [2, 4]}'\
     '0.0.0.0:8080/train_model'
```

```bash
# Ejemplo de POST para un solo user: 
curl -X POST -H "Content-Type: application/json"\
     -d '{"gender": 1, "age": 67, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}'\
     0.0.0.0:8080/user
```

```bash
# Ejemplo de DELETE para user: 
curl -X DELETE '0.0.0.0:8080/user?id=2'
```

```bash
# Ejemplo de GET para user: 
curl '0.0.0.0:8080/user?id=3'
```

```bash
# Ejemplo de PATCH para user: 
curl -X PATCH -H "Content-Type: application/json"\
     -d '{"gender": 0, "age": 6700, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}'\
     '0.0.0.0:8080/user?id=4'
```

```bash
# Ejemplo de GET para users (regresa toda la base de datos): 
curl '0.0.0.0:8080/users'
```

```bash
# Ejemplo de POST para múltiples users: 
curl -X POST -H "Content-Type: application/json"\
     -d '[{"gender": 1, "age": 67, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}, 
          {"gender": 0, "age": 64, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}]' \
          0.0.0.0:8080/users
```

```bash
# Ejemplo de DELETE para múltiples users: 
curl -X DELETE -H "Content-Type: application/json"\
     -d '{"id": [1,2,3,4,5,6,7,8]}'\
     '0.0.0.0:8080/users'
```

```bash
# Ejemplo de Predicción con un modelo en específico (CUIDADO DE CHECAR LA FECHA!)
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":
			{
					"gender": 1, 
					"age": 2, 
					"hypertension": 0, 
					"heart_disease": 1, 
					"ever_married": 1, 
					"Residence_type": 1, 
					"avg_glucose_level": "1000.69", 
					"bmi": "36.6",
					"smoking_status": 1
			},

	"model":
			{
					"version": "modelos_locales",
					"year": "2021",
					"month": "12",
					"day": "05",
					"hour": "01",
					"minute": "23",
					"second": "10"
			}
}'\
     '0.0.0.0:8080/predict'
```

```bash
# Ejemplo de Predicción con el modelo dentro del docker más reciente
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":{"gender": 1, "age": 2, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "1000.69", "bmi": "36.6","smoking_status": 1},
	"model": {"version": "latest_local"} }'\
     '0.0.0.0:8080/predict'     
```

```bash
# Ejemplo de Predicción con el modelo fuera de docker más reciente (Carpeta /app/modelos)
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":{"gender": 1, "age": 2, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "1000.69", "bmi": "36.6","smoking_status": 1},
	"model": {"version": "latest"} }'\
     '0.0.0.0:8080/predict'
```

```bash
curl -X POST -H "Content-Type: application/json"\
     -d '{"year": "2021","month": "12","day": "05","hour": "01","minute": "23","second": "10"}' \
     '0.0.0.0:8080/save_model'
```

```bash
# Salvar el modelo más reciente a modelos.
curl '0.0.0.0:8080/save_model'
```

### URLs útiles

Además de utilizar curl, muchas de las funciones de la aplicación están en un URL específico: 

* Página de inicio:`http://localhost:8080/#` 
* JSON de los usuarios: `http://localhost:8080/users`
* Tabla de los usuarios: `http://localhost:8080/tabla_usuarios`
* Se entrena un modelo con la base de datos como está: `http://localhost:8080/train_model`
* Mostrar los modelos entrenados guardados en el Docker: `http://localhost:8080/show_local_models`
* Guardar modelo más reciente en el folder fuera del Docker de `/app/modelos`: `http://localhost:8080/save_model`
* Mostrar los modelos en el folder fuera del Docker de `/app/modelos`: `http://localhost:8080/show_models`
* Mostrar gráfica de importancia para el modelo más nuevo: `http://localhost:8080/plot.png`
* Guardar el modelo entrenado más reciente en la carpeta de `/app/models`, esta está fuera del docker y se conecta a través de un volumen: `http://localhost:8080/save_model`. 
* Mostrar resultados de los modelos guardados localmente, es decir, en /app/modelos: `http://localhost:8080/show_results`

### Problemas a los que nos enfrentamos

* Nunca pudimos hacer la carga inicial de los datos desde el Dockerfile. Esto es ya que se necesita que esté prendida la concección a `http://localhost:8080`, pero, esto solamente sucede cuando ya se corrió el `ENTRYPOINT`. Por lo tanto, decidimos que poner el comando de `docker exec` sería una buena solución a esto. 
* Por alguna razón, si una persona en Windows bajaba el archivo desde git, no jalaba correctamente el archivo de `limpieza.sh` logramos resolverlo al comprimir el archivo y pasarlo entre nosotros, pero es un comportamiento que no sabemos como corregir. 

### Extensiones de este trabajo

Lo que presentamos aquí es una aplicación con procesos de backend buenos y relativamente complejos, pero algo que le falta bastante es una buena interfaz gráfica. Las aplicaciones de Flask generalmente tienen  mucho detrás de ellas y nosotros desconocemos muchas de las tecnologías que se usan en desarrollo web o de aplicaciones móviles. Por lo tanto, muchas de las páginas que presentamos son muy básicas, o les falta algo de contenido. Mientras que los sistemas detrás de todo funcionan bien, tal vez con trabajo o con el apoyo de otra persona que le sepa a temas de diseño web podamos hacer una aplicación mucho más completa y comprensiva. 

Otra posible extensión es que por el momento, solamente estamos usando modelos de Random Forest para entrenar los datos. Sería bueno e interesante poder cargar otros tipos de modelos, y hacer la aplicación más robusta en ese sentido. 

Por ahora, estamos felices con las cosas que presentamos en términos de back end, y es completamente reproducible, que es algo que nos gusta mucho de todo. Además, se puede muy fácilmente actualizar para incluir bases de datos distintas o cambiar la estrictura de la que ya se tiene para poder agregar variables o observaciones, por lo tanto estamos también felices con esta flexibilidad. 

### Referencias

* [Base de Datos](https://www.kaggle.com/fedesoriano/stroke-prediction-dataset)

* https://towardsdatascience.com/the-right-way-to-build-an-api-with-python-cd08ab285f8f

* https://www.techwithtim.net/tutorials/flask/adding-bootstrap/

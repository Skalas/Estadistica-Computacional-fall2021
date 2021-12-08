![](https://github.com/cecyar/rodent_inspection/blob/main/images/rod_insp_logo.png) ![](https://github.com/cecyar/rodent_inspection/blob/main/images/itam.png)

## Estadística Computacional (Otoño 2021)
## QUARANTEAM, Proyecto Final: Rodent Inspection
	
### Integrantes del equipo

| Nombre                           |  CU    | Mail               | Usuario Gh |
|----------------------------------|--------|--------------------|------------|
| Luz Aurora Hernández Martínez    | 178831 | lhern123@itam.mx   | LuzVerde23 |
| Ita-Andehui Santiago Castillejos | 174134 | isantia2@itam.mx   | sancas96   |
| Cecilia Avilés Robles            | 197817 | cavilesr@itam.mx   | cecyar     |
| Leonardo Ceja Pérez              | 197818 | lcejaper@itam.mx   | lecepe00   |

## Pregunta analítica a contestar
¿Pasará una propiedad una inspección de ratas o no?  En otras palabras, ¿se encontrarán ratas en dicha propiedad?

El modelo consiste en una clasificación binaria con las siguientes etiquetas:

- `Etiqueta 0:`  La propiedad **SÍ** pasará la inspección de ratas (no se encontrarán ratas en la propiedad).
- `Etiqueta 1:`  La propiedad **NO** pasará la inspección de ratas (sí se encontrarán ratas en la propiedad.)

# Comprensión del negocio
Consulte el documento [00_comprension_negocio.md](https://github.com/cecyar/rodent_inspection/blob/main/00_comprension_negocio.md)

# Base de datos
La base de datos que se analizará en este trabajo será la de [Rodent inspection](https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj) obtenida de [NYC Open Data](https://opendata.cityofnewyork.us/).

# Infraestructura y Ejecución ⚙

Para ejecutar este producto de datos se necesita lo siguiente:
- Sistema operativo Linux/Mac con Docker Desktop instalado.
- Clonar el repositorio en el equipo.

**Para levantar la imagen de docker y la base de datos:**
1. Descargar el archivo `Rodent.csv` que está disponible en este [**Drive**](https://drive.google.com/file/d/1JCXlYAfIUP7xOGPAxS-MUKE1sNXJMWKl/view?usp=sharing), y colocarlo en la carpeta `data` del repositorio.
2. Limpieza de datos: 
   1. Abrir una terminal, ir a la raíz del repositorio, y ejecutar estos dos comandos:
      1. > `awk -f src/clean_data.awk < data/rodent.csv`
      2. > `sed -r '/(^|,)\s*(,|$)/d' data/rodent_reduced.csv > data/Rodent_Inspection.csv`
3. Construir la imagen de docker:  
   1. En la raíz del repositorio, ejecutar estos 2 comandos en la terminal (se necesitará ingresar la contraseña del usuario de la computadora donde se está trabajando):
      1. > `make build`
      2. > `make up`

**Para acceder a los servicios del producto de datos:**
1. Abrir el explorador de internet e ir a la siguiente dirección:
   1. > `localhost:5000/main`
2. Se accede a la página principal que contiene 4 botones con las siguientes funciones:
   1. `Mostrar datos`:  Muestra la tabla disponible en la base de datos con el dataset utilizado para entrenar el modelo.  **Nota:**  Debido al tamaño del dataset usado para el entrenamiento (196,000 registros), se muestran solo 20 registros para fines ilustrativos.
   2. `Realizar predicción`:  Permite realizar una predicción, al ingresar los campos requeridos.
      1. `Job ID`:  Identificador de la predicción, valor numérico libre.
      2. `Borough Code`:  Identificador numérico del distrito de Nueva York a inspeccionarse, 5 valores numéricos posibles:
         1. Manhattan (1)
         2. Bronx (2)
         3. Brooklyn (3)
         4. Queens (4)
         5. Staten Island (5)
      3. `Zip Code`:  Código postal donde se realizará la inspección (valor numérico entre 10001 y 11220). 
      4. `Latitude`:  Latitud donde se realizará la inspección (valor numérico entre 40.49 y 40.92).
      5. `Longitude`:  Longitud donde se realizará la inspección (valor numérico entre -74.27 y -73.68).
      6. `Inspection type`:  Tipo de inspección a realizarse, seleccionar alguna de las siguientes opciones:
         1. Bait
         2. Clean up
         3. Compliance
         4. Initial
         5. Stoppage
   2. `Agregar registro`:  Permite agregar observaciones adicionales a la base de datos.
   3. `Mostrar predicciones`:  Se muestran las predicciones realizadas hasta el momento.
3. Adicionalmente, se puede visualizar y trabajar con la base de datos utilizando el servicio de `pgAdmin`, para ello, ejecutar lo siguiente:  
   1. Abrir el explorador de internet e ir a la siguiente dirección:
      1. > `localhost:8000`
   2. Después de visualizar la pantalla de bienvenida de `pgAdmin`, ingresar los siguientes datos:
         1. username:  admin@admin.com
         2. password:  admin
   3. Después de entrar al servicio de `pgAdmin`, dar click derecho sobre `Servers` en el menú de la izquierda, seleccionar `Create` y posteriormente `Server`.
   4. En la ventana que se despliega, capturar la siguiente información:
      1. Pestaña `General`: Darle nombre al servidor, por ejemplo: `Rodent`.
      2. Pestaña `Connection`:  
         1. Host name:  db
         2. Username:  root
         3. Password:  root
   5. Estarán disponibles las siguientes tablas:
      1. `all_info`:  Contiene los registros del dataset de entrenamiento del modelo.
      2. `predicted_results`:  Contiene las predicciones realizadas.  
4. Para salir de este producto de datos, hay que cerrar las pestañas del explorador y ejecutar `Ctrl+C` en la terminal donde se está corriendo la imagen de Docker.

**Re-Entrenamiento del modelo:**
1. Para re-entrenar el modelo es necesario ejecutar el notebook [Model_rodent.ipynb](https://github.com/cecyar/rodent_inspection/blob/main/notebooks/Model_rodent.ipynb) que se encuentra en la carpeta `notebooks` del repositorio.  Para ello, será necesario exportar la table `all_info` actualizada como archivo `*.csv` a través de `pgAdmin` y colocarla en la carpeta `data` del repositorio.
2. Los modelos que se generan en formato `pickle` al ejecutar el notebook, deben colocarse en la carpeta `data` del repositorio.  **Nota:**  Para ejecutar el notebook, es necesario utilizar algún ambiente virtual adicional que contenga `jupyter notebook`.  La imagen de Docker de este producto de datos no contiene `jupyter notebook`.

# EDA
Se puede consultar el análisis exploratorio de datos en la siguiente carpeta:  [EDA](https://github.com/cecyar/rodent_inspection/tree/main/notebooks/eda)

**Nota:**  Este análisis exploratorio se realizó con el dataset original con los registros al 16 de Noviembre de 2021.  El dataset original cuenta con más de 2 millones de registros.  

Para facilitar la creación de este producto de datos, se utilizó un dataset reducido de aproximadamente 200,000 registros, disponible en el [**Drive**](https://drive.google.com/file/d/1JCXlYAfIUP7xOGPAxS-MUKE1sNXJMWKl/view?usp=sharing) mencionado anteriormente.

# Entrenamiento
Se puede consultar los detalles del entrenamiento del modelo de predicción en el notebook: [Model_rodent.ipynb](https://github.com/cecyar/rodent_inspection/blob/main/notebooks/Model_rodent.ipynb).


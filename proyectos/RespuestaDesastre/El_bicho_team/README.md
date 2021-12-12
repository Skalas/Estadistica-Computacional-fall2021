# Proyecto Respuesta Desastres

:wave: :wave: 

## Integrantes del equipo

Nombre|Clave Única|Correo|User de Github | 
|:---:|:---:|:---:|:---:|
|Fernando Miñaur Olivares|158125|fminaurol@gmail.com|@Fminaurol|
|Juan Humberto Escalona|203131|jescalon@itam.mx|@Juanes8|
|Carlos López de la Cerda|158122|carlos.lopezdelacerda@itam.mx|@kennyldc

## Explicación breve de lo que se hizo
Para el proyecto, inciamos cargando las hojas del archivo de excel para poder incluirlas a nuestro programa. Posteriormente se limpian las coordenadas de longitud y latitud para poder cargarlas y utilizar en leaflet. Encontramos coordenadas con menos de 10 cifras por lo que se eliminaron. Antes de iniciar la configuración del servidor se diseñó la función para encontrar las distancias más cortas a las coordenadas proporcionadas. Para la aplicación se incluyeron tres pestañas. En la primer pestaña se pueden cargar todos los datos de nuestros refugios o bien filtrar solo algunos municipios de elección. En el segundo, se observa la localización de todos los refugios o bien filtrar solamente los de algunos municipios. En la última pestaña, se puede elegir una ubicación y al dar clik en localizar encuentra el refugio más cercano. 
El archivo que permite que funcione la aplicación lo nombramos `app.R`.
## Dificultades
Al no ser usarios enfocados en R principalmente, fue un poco complicado adaptar funciones o variables que usaríamos en Python. Sin embargo, encontramos mucha documentación acerca de Shiny que nos sirvieron para crear el server de nuestro proyecto. Sin duda una de las cuestiones más complicadas fue crear el apuntador para encontrar el refugio más cercano. Además, cargar el archivo desde excel con multiples hojas representó un problema en principio y al lograr cargar las primeras fue cuestión de adaptar el modelo.
## Conclusiones
En este proyecto, pudimos practicar la limpieza de bases de datos, la creación y el diseño de aplicaciones usando Shiny que era algo nuevo para todos nosotros. El ejercicio fue útil para prácticar nuestras habilidades con el lenguaje R y crear un producto implementable para situaciones reales como lo es una situación de desastre.

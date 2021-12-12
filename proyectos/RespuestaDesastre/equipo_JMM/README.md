![](https://mcdatos.itam.mx/wp-content/uploads/2020/11/ITAM-LOGO.03.jpg)

# Tarea 1 

## **Integrantes**

| Nombre | CU | Mail | Usuario Gh |
|:--:|:--:|:--:|:--:|
|Mario Arturo Heredia Trejo | 197863  | mhered15@itam.mx | mhnk77 |
| Joel Jaramillo Pacheco | 030615 | joel.jaramillo@itam.mx | joelitam2021 |
| Miguel Ángel Reyes Retana | 045799 | mreyesre@itam.mx | rrmiguel-2401 |

## Procedimiento

Al principio tuvimos una reunión para comprender el problema y discutir la manera de abordarlo 
definiendo roles de cada uno de los participantes. Acordamos abordar el problema de manera individual 
y reunirnos posteriormente para discutir la mejor opción para resolverlo, de acuerdo con lo revisado.


La primera parte fue una inspección de los datos. Creamos la carpeta **"cleaning"** para ello. La importación de los datos se codificó para que se realizara de forma automática, considerando los 
encabezados del archivo de refugios. Después de discutir dos métodos escogimos el que importaba los datos 
de manera más eficient para leerlos, para ello utilizamos el script **"01_cargar_juntar_datos.R"** y guardarlos como: **"data_merged.rds"**. Para limpiar las columnas, utilizamos el script **"02_limpia_columnas.R"** donde reemplazamos los caracteres incongruentes en el formato formato ddºmm'ss.ss y revisamos que estuvieran
en el rango de latitud y longitud correspondiente a Nayarit. Para los datos faltantes o errores que no eran factibles modificar con código, decidimos hacer un archivo Excel **("imputaciones_reservas.xlsx")** con las mismas características del archivo original, pero solo con los registros que serán imputados. La información faltante se consiguió vía internet y los errores de codificación se cambiaron a mano. La imputación se hace dentro del script 02_limpia_columnas.R. cargando el archivo y remplazando los registros correspondientes tomando como llave el número de centro (No.). Con el paquete *sp* de R transformamos a numérico la 
latitud y la longitud. De aquí obtuvimos la base de datos **"data_clean.rds"**


Con los datos limpios, creamos la carpeta *src*. Ahí realizamos el script **"01_algoritmo_distancia.R"**  para calcular la distancia angular entre 
dos puntos tomando como entrada la latitud y la longitud utilizando la librería *geosphere* de R. En este script corroboramos que la función que calcula la disancia, lo hiciera correctamente. En el 
script **"02_mapa_lite.R"** se creó la función para mapear el estado, añadir los marcadores y utilizar la función de distancia
creada en el primer script.


Para la elaboración del dashboard creamos la carpeta **"shiny"**, donde utilizamos la librería con el mismo nombre. 
Este paquete permite creación de aplicaciones web de manera interactiva para que cualquier persona lo pueda revisar y 
visualizarlo sin tener que programar y definimos las funciones en el scipt **"global.R"**, en este archivo creamos el mapa base, la función de calcular la 
distancia y generamos una tabla que muestra los refugios cercanos al punto seleccionado. En **"ui.R"** construimos la interfaz
del usuario, donde decidimos manejarlo por pestañas para una mejor visualización; en el archivo **"server.R"** es donde se
crean todos los objetos variables de la aplicación, de acuerdo con la interacción del usuario.


## Dificultades


En este proyecto las dificultades empezaron desde el entendimiento del problema, porque teníamos percepciones distintas
 de lo que pretendíamos que se tenía que entregar. Otra dificultad fue el uso del repositorio, aunque creamos uno para ir 
trabajando el proyecto de manera privada, no teníamos claro cómo estructurarlo.

En la etapa de limpieza de datos, la mayor dificultad fue el archivo fuente. El archivo Excel proporcionado, no está optimizado para ser manejado como entrada a un sistema informático. El archivo contiene imágenes de logotipos, celdas agrupadas, distintos símbolos para identificar los grados, minutos y segundos de las coordenadas geográficas, entre otros errores. Por lo que fue necesario hacer distintas fases de limpieza.

En la etapa de la creación de los mapas tuvimos dos opciones, en la primera utilizamos una capa de un archivo geojson 
para graficar el estado, pero resultaba ineficiente por el tamaño de la base de datos. Al final decidimos utilizar una aplicación
más ligera y visualmente atractiva. 


En el desarrollo del proyecto, el código utilizado, no siempre fue óptimo y por ello lo reemplazamos un par de ocasiones
para asegurar que fuera conciso, descriptivo y eficiente. 



## Conclusiones


Lo que obtuvimos es un dashboard, que al ingresarle coordenadas de latitud y longitud, desde el dashboard, nos muestra en un mapa los refugios más
cercanos y en una tabla despliega una lista con datos de contacto de aquellos refugios más cercanos a las coordenadas ingresadas. Así como la localidad a la que pertenecen.

Como contexto del problema, consideramos esta forma de presentar los datos es útil porque si se van a mandar víveres por parte de personas fuera de Nayarit,
se puede considerar buscar una dirección y obtener las coordenadas geográficas de latitud y longitud para saber dónde está
el refugio más cercano y poder enviar víveres o ayuda a la localidad, de acuerdo con las características del refugio seleccionado.


## Guía de uso

Para la correcta ejecución de esta solución es necesario:

Descargar la solución respetando la siguiente estructura de archivos y directorios

./cleaning/ 01_cargar_juntar_datos.R

            02_limpia_columnas.R

./data/imputaciones_reservas.xlsx

       refugios_nayarit.xlsx

./rds/readme.md

./shiny/global.R

        server.R
	
        ui.R
        
        www/infra_tran_nayarit.png
        
/src/01_algoritmo_distancia.R

     02_mapa_lite.R
 

Definir el área de trabajo en la consola de C, seleccionando el directorio raíz de la solución 
ejemplo; setwd(“proyectos/RespuestaDesastre/<tuproyecto>/”

Ejecutar los scripts en la siguiente secuencia

 a)	Limpieza de datos: 

    01_cargar_juntar_datos.R

    02_limpia_columnas.R

    (al final de estos scripts se crean los archivos data_clean.rds, data_merged.rds en el directorio rds)

 b)	creación de mapa

    01_algoritmo_distancia.R

    02_mapa_lite.R

 c)	solución shiny

    shiny::runApp()


















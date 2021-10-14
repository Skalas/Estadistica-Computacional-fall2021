# <p align = "center"> QUARENTEAM
## <p align = "center"> Estadística Computacional (Otoño 2021)

# Proyecto Respuesta Desastres
	
### Intergantes del equipo  🚀
	

| Nombre                           |  CU    | Mail                     | Usuario Gh |
|----------------------------------+--------+--------------------------+------------|
| Cecilia Avilés Robles	           | 197817 | cavilesr@itam.mx         | cecyar     |
| Luz Aurora Hernández Martínez    | 178831 | lhern123@itam.mx         | LuzVerde23 |
| Ita-Andehui Santiago Castillejos | 174134 | isantia2@itam.mx         | sancas96 |
| Leonardo Ceja Pérez              | 197818 | lcejaper@itam.mx         | lecepe00   |

### Pasos a seguir 📋

De manera loca, en la carpeta data hay que colocar el archivo que se encuentra en [esta liga](https://docs.google.com/spreadsheets/d/0Bw4a10rhk2QqaTZkUmQwaXU4aEE/edit?usp=sharing&ouid=101036910978943156470&resourcekey=0-RQa9gRpFX0x3z5bSJGn0Dg&rtpof=true&sd=true) **con el mismo nombre**

Es importante, antes de comenzar el archivo [`ETL.Rmd`](https://github.com/LuzVerde23/Estadistica-Computacional-fall2021/blob/main/proyectos/RespuestaDesastre/quarenteam/ETL.Rmd) se deberá de correr de forma local. Este archivo nos genera otro archivo `.rds`, este último es el que alimentará nuestra interfaz de `shiny`


### Explicación breve de lo que se hizo ✒️

Para este proyecto contamos con la información proporcionada por la Dirección de Protección Civil y Bomberos del estado de Nayarit, los cuales concentraron datos como ubicación, capacidad, responsable entre otros. Los pasos que se siguieron a manerade resumen fueron los siguientes:

	1. Primero se realizó la carga de estos.
	2. Una breve visualización de los datos para irlos conociendo, 
	3. Posteriormente hacer una limpieza de estos mismos: corrección de escritura de coordenadas o "volteadas", `NAs`. etc.
	4. Breve visualización de estos: Boxplot y mapa.
	5. Interfaz de **`shiny`**

Todo esto se puede visualizar en el archivo [`ETL.Rmd`](https://github.com/LuzVerde23/Estadistica-Computacional-fall2021/blob/main/proyectos/RespuestaDesastre/quarenteam/ETL.Rmd)

Por su parte la interfaz de `shiny` generar un motor sencillo que indica el refugio más cercano a una coordenada dada. También, genera un dashboard que ayuda a identificar por localidad los refugios existentes.

### Dificultades ⚙️

Hablando del ETL las dificultadas que se afrontaron fueron las relacionadadas a dos puntos:

	1. Limpieza de los datos: desde encontrar la mejor manera de cargar los datos, hasta el manejo de los `NAs`. 
	2. Uso de coordenadas: encontrar la mejor manera de manipular las coordenadas.

Para los puntos anteriores fue importante investigar, leer y entender las paqueterias (leaflet, parzer, etc.) que ocupamos para así sacarle el mejor provecho a nuestro `dataset`.

Por su parte el reto de implementar el `shiny` los retos importantea resaltar fue poder hacer el `dashbord` que no sólo nos mostrara el mapa, sino que también que desde este mismo se tomara como `input` las coordenadas que le ingra el **usuario**

### Conclusiones 📄

Aunque nos queda claro que hay mucho que aprender para la implementación de un `dashbord` mucho más robusto es importante resaltar que no quisimos ser redundantes y ostentosos con las tareas que se solicitan, ya que al ser inexpertos en el tema, a la hora de investigar herramientas que nos ayuden en la implementación es fácil perderse en el mar de información que se puede encontrar.

Esperamos también, que este dashboard sea de utilidad para el **usuario** y que también sea de un amigable manejo para este.


![](https://mcdatos.itam.mx/wp-content/uploads/2020/11/ITAM-LOGO.03.jpg)

# QUARENTEAM

## Estadística Computacional (Otoño 2021): Proyecto Respuesta Desastres
	
### Integrantes del equipo  🚀

| Nombre                           |  CU    | Mail                     | Usuario Gh |
|----------------------------------|--------|--------------------------|------------|
| Cecilia Avilés Robles	           | 197817 | cavilesr@itam.mx         | cecyar     |
| Luz Aurora Hernández Martínez    | 178831 | lhern123@itam.mx         | LuzVerde23 |
| Ita-Andehui Santiago Castillejos | 174134 | isantia2@itam.mx         | sancas96 |
| Leonardo Ceja Pérez              | 197818 | lcejaper@itam.mx         | lecepe00   |


### Instrucciones 📋

Para poder reproducir nuestro trabajo, por favor sigue los siguientes pasos:

 1. Clona el repositorio.
 2. De manera local, coloca en la carpeta `data` el archivo que se encuentra en [esta liga](https://docs.google.com/spreadsheets/d/0Bw4a10rhk2QqaTZkUmQwaXU4aEE/edit?usp=sharing&ouid=101036910978943156470&resourcekey=0-RQa9gRpFX0x3z5bSJGn0Dg&rtpof=true&sd=true). Favor de utilizar **el mismo nombre**.
 3. Abre y ejecuta el archivo [`ETL.Rmd`](https://github.com/LuzVerde23/Estadistica-Computacional-fall2021/blob/main/proyectos/RespuestaDesastre/quarenteam/ETL.Rmd). Este archivo nos genera un archivo `.rds`, que es con el que se alimentará nuestra interfaz de `shiny`.
 4. Posteriormente, ejecuta el archivo `app.R` para poder visualizar el `dashboard`. Recuerda siempre dar click en el botón `Recalcular selección`.
    - La pestaña `MapaT` muestra el mapa con todos los refugios disponibles, categorizándolos de acuerdo a su capacidad.
    - La pestaña `MapaD` muestra el refugio más cercano con base en la coordenada proporcionada.
    - La pestaña `MapaL` muestra los refugios en la localidad seleccionada.

### Explicación breve de lo que se hizo ✒️

Para este proyecto contamos con la información proporcionada por la Dirección de Protección Civil y Bomberos del estado de Nayarit, los cuales concentraron una base de datos de los refugios disponibles con datos como: ubicación, capacidad, responsable, entre otros. Los pasos que se siguieron, a manera de resumen, fueron los siguientes:

 1. Primero se realizó la carga de los datos.
 2. Después se hizo una breve visualización de éstos para irlos conociendo. 
 3. Posteriormente, se hizo una limpieza de los mismos: corrección de escritura de coordenadas, acomodo para las que estaban volteadas, `NA's`, etc.
 4. Breve visualización de éstos: Boxplot y mapa.
 5. Interfaz de `shiny`.

Todo esto se puede visualizar en el archivo [`ETL.Rmd`](https://github.com/LuzVerde23/Estadistica-Computacional-fall2021/blob/main/proyectos/RespuestaDesastre/quarenteam/ETL.Rmd).

Por su parte, la interfaz de `shiny` genera un motor sencillo que indica el refugio más cercano a una coordenada dada. Adicionalmente, genera un `dashboard` que ayuda a identificar por localidad los refugios existentes. Cada una de estas opciones pueden visualizarse en las diferentes pestañas de nuestro `dashboard`.

### Dificultades ⚙️

Hablando del ETL, las dificultades que se afrontaron fueron las siguientes:

 1. Limpieza de datos: desde encontrar la mejor manera de cargar los datos, hasta el manejo de los `NA's`. 
 2. Uso de coordenadas: encontrar la mejor manera de manipular las coordenadas.

Para los puntos anteriores fue importante investigar, leer y entender las paqueterías que ocupamos (como leaflet, parzer, etc.) para así sacarle el mejor provecho a nuestro dataset.

Asimismo, en la implementación de `shiny` los retos importantes a resaltar fueron: poder hacer un `dashboard` que no sólo nos mostrara el mapa, sino que también se actualizara con los `inputs` de las coordenadas que le ingresa el **usuario**.

### Conclusiones 📄

Aunque nos queda claro que hay mucho que aprender para la implementación de un `dashboard` mucho más robusto, es importante resaltar que no quisimos ser redundantes y ostentosos con las tareas que se solicitan. Al no ser expertos en el tema, a la hora de investigar acerca de las herramientas que nos ayudaron en la implementación, era fácil perderse en el mar de información que se podía encontrar. Sin embargo, confiamos en que estas investigaciones nos ayudarán a seguir desarrollando nuestras habilidades para así poder implementar proyectos más ambiciosos en el futuro.

Esperamos también que este `dashboard` sea de utilidad para el **usuario** y que el manejo del mismo sea amigable.


# Proyecto Respuesta Desastres
## Intergantes del equipo

|          Nombre          |   CU   |      e-mail      | usuario github |
|:------------------------:|:------:|:----------------:|:--------------:|
| Miguel Calvo Valente     | 203129 | mcalvova@itam.mx | mig-calval     |
| Adrian Tame Jacobo       | 142235 | atamejac@itam.mx | AdrianTJ       |
| Rodrigo Juárez Jaramillo | 145804 | rjuarezj@itam.mx | ro-juja        |

## Explicación breve de lo que se hizo
Hicimos una interfaz con Shiny para poder ubicar los refugios más cercanos dada una ubicación en coordenadas o dentro de un municipio. Agregamos también una página de inicio donde pusimos un mapa donde se hacer click para facilitar encontrar la unicación de un usuario en caso de no saberla. 
Además de esto, implementamos una interfaz pequeña para hacer un cambio de tema. 
La limpieza de datos está hecha en otro archivo llamado `refugios.R`, donde incuimos también varias funciones que utilizamos en la aplicación. 

## Decisiones que Tomamos
Eliminamos todos los renglones en los que no hay latitud, longitud o municipio. Una mejora que podría implementarse más adelante, sería recuperar los municipios faltantes a partir de las coordenadas con las que contamos.
Quitamos los casos en los que las coordenadas no estaban en formato correcto. Se filtró de acuerdo al rango que detectamos que pertenecían los municipios de Nayarit.
Decidimos mostrar los 5 refugios más cercanos dada una ubicación. En caso que hubiera coordenadas repetidas, en los popus se muestran los datos de dichos refugios con coordenadas repetidas.
Decidimos que el usuario ingresara las coordenadas en D (Degrees), M (Minutes) y S(Seconds) en vez de en decimal. Para facilitar la adquisición de las coordenadas en este formato, la ubicación que se elije en el mapa interactivo se muestra tanto en formato decimal como en D-M-S.

## Dificultades
Tuvimos muchas. Inicialmente, lo más complicado para nosotros fue entender Shiny. Nunca habíamos trabajado con Shiny, ni con leaflet, entonces nos tomó algo de tiempo acostumbrarnos a la interfaz y poder manejarla con algo de confianza. 

Tuvimos varios problemas con datos `NA`. Lo que hicimos fue quitar los datos que no tenian coordenadas o municipio. Esto ya que, sin estos valores, no nos es posible ubicarlos en el mapa. Una mejora podría ser que a partir del nombre del refugio y de alguna API pudieramos recuperar las coordenadas.

Encontramos que habían varios refugios con las mismas coordenadas, pero en los popups solo aparecia uno. Para solucionarlo, modificamos los dataframes para que se mostraran ya todos los refugios y telefonos tanto en el popup como en la tabla.

Otro problema que tuvimos fue con el mapa de la página de inicio. Este originalmente queríamos que fuera interactivo tal que al darle click, te regresara las coordenadas y los refugios más cercanos. Sin embargo, no lo logramos. Esto ya que la posición inicial del mouse era `NA`, y al momento de que se cargara la App, nos marcaba un error y el mapa ya no se desplegaba. No obstante, logramos que se mostraran las coordenadas una vez se le diera click para que el usuario las copie y pegue.

Los temas originalmente queríamos que fuera un *dark mode*, pero no pudimos implementarlo de manera completa. Decidimos mejor usar una solución existente de un paquete para implementar el cambio de tema, y de esta forma el usuario pueda elegirlo y tener una experiencia personalizada.

Las coordenadas inicialmente no estaban en un formato listo para ocuparse. Se requirió manipulaciones y transformaciones a través del uso de expresiones regulares para poder utilizarlas. De igual forma, la limpieza y estandarización de la base resultó desafiante.

Finalmente, intentamos colorear el mapa por Municipio. Intentamos de varias formas, sin embargo consideramos que requeriríamos más conocimiento de los paquetes y de la forma de trabajar con coordenadas geográficas. Se queda como una mejora.

## Conclusiones

Estamos satisfechos con el resultado. Aprendimos a usar Shiny, expresiones regulares, lectura y manipulacion de archivos con estructuras distintas a csv, y en general, un mejor entendimiento de un proceso de datos from scratch. Hay varias mejoras que aún nos gustaría implementar, pero creemos que el resultado cumple con los requerimientos. 

Nos dimos cuenta de la importancia que tiene Shiny para poder presentar resultados. Al haber trabajado y hecho reprotes exclusivamente en RMarkdown, perdemos mucha interactividad con el usuario final, y además, en Shiny ganamos muchos elementos de diseño visual que no podemos incorporar en RMarkdown. 

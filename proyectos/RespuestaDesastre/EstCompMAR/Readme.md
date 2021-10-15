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

## Dificultades
Tuvimos muchas. Inicialmente, lo más complicado para nosotros fue entender Shiny. Nunca habíamos trabajado con Shiny, ni con leaflet, entonces nos tomó algo de tiempo acostumbrarnos a la interfaz y poder manejarla con algo de confianza. 

Tuvimos varios problemas con datos `NA`, pero los logramos solucionar. Lo único que hacemos es quitar los datos que no tienen coordenadas, nombre o municipio. Esto ya que los usamos en los cálculos, y si en algún evento se agregaran más datos a el excel original, nos gustaría no tener problemas en el futuro de que se rompa la aplicación. 

Encontramos que habían varios refugios con las mismas coordenadas, y decimimos que el mejor proceso era mostrarlas todas en la tabla que enseña estos refugios, pero en el mapa queríamos mostrarlos todos. Esto tomó un esfuerzo bastante considerable. 

Otro problema que tuvimos es con el mapa de la página de inicio. Este originalmente queríamos que fuera de picarlo y que te regresara las coordenadas y los refugios más cercanos, pero no lo logramos. Esto ya que los daba que la posición inicial del mouse era `NA`, y por lo tanto, no funcionaba.

Los temas originalmente queríamos que fuera un *dark mode*, pero, no pudimos implementarlo de manera completa. Decidimos mejor usar una solución existente de un paquete para implementar el cambio de tema, y nos resultó un buen cambio, ya que pudimos intentar con varios de ellos, y no solo oscuro o claro. 

Las coordenadas también entraban como texto al modelo. La primera vez que nos juntamos a trabajar, pasamos el tiempo completo haciendo lectura de los datos y limpiándolos, y pasándolos a un formato más legible numérico. Esto resultó bueno, ya que lo usamos varias veces en distintos lugares para hacer cálculos. 

Finalmente, intentamos colorear el mapa por Municipio. Tristemente, no lo logramos. Intentamos de varias formas pero creemos que nuestro entendimiento de las funciones detrás de cómo hacerlo es bajo, y requeriríamos más experiencia o más tiempo para pdoer hacerlo. Independientemente de esto, nos dmucho gusto que pudimos obtener las coordenadas en el mapa de municipios. 

## Conclusiones

Dejamos algunas cosas en la mesa que podríamos mejorar. Por ejemplo, 
* Unificar el output de texto, para que todas las coordenadas estén en el mismo formato. 
* Lo de la coloración del mapa, nos hubiera gustado. 
* Un diseño de página un poco más fino. 
* Jalar la coordenada a partir del mapa, para mejorar la experiencia del usuario. 

Independientemente de esto, honestamente estamos muy contentos con el resultado. No nos da warnings, que es muy bueno, y aprendimos juntos a usar Shiny. Tal vez hay mejoras grandes que se pueden hacer, pero, creemos que el resultado es completo y cumple su propósito. 

Nos dimos cuenta de la importancia que tiene Shiny para poder presentar resultados. Al haber trabajado y hecho reprotes exclusivamente en RMarkdown, perdemos mucha interactividad con el usuario final, y además, en Shiny, ganamos muchos elementos de diseño visual que no podemos incorporar en RMarkdown. 

No estamos diciendo que es mejor o peor siempre, pero hay casos (como este) donde definitivamente es bueno tener la herramienta de Shiny en la bolsa. 













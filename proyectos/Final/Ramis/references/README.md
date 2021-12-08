### Data dictionaries, manuals, and all other explanatory materials.

El objetivo de este folder será integrar los materiales de referencia requeridos así como documentar la investigación inicial que desarrollemos
durante la definición de nuestro proyecto. 

Para evitar subir archivos de BD, el proceso de documentación de la investigación consiste en lo siguiente:
1. Indicar la liga a la fuente de información.
2. Describir brevemente el DataSet, los _insights_ que debe cubrir el proyecto de Ciencia de Datos y el potencial observado (máx. 5 líneas por proyecto)

1. **Insurance Company Benchmark (COIL 2000).**
Este dataset se utilizó en el concurso CoIL 2000 Challenge, refiere información acerca de clientes en una cía de seguros, consiste en 86 variables
de información del producto y socio-demográficas. Contiene aproximadamente 5000 registros de train y 4000 de test (no contiene la variable respuesta), por lo que
estaríamos modelando prácticamente con 5000 observaciones. El conjunto de entrenamiento contiene la variable respuesta binaria si o no se tiene una póliza para
caravan (remolque). Se adiciona la siguiente información del dataset:

> TICDATA2000.txt: Dataset to train and validate prediction models and build a description (5822 customer records). Each record consists of 86 attributes,
containing sociodemographic data (attribute 1-43) and product ownership (attributes 44-86).The sociodemographic data is derived from zip codes. All customers
living in areas with the same zip code have the same sociodemographic attributes. Attribute 86, "CARAVAN:Number of mobile home policies", is the target
variable.
> TICEVAL2000.txt: Dataset for predictions (4000 customer records). It has the same format as TICDATA2000.txt, only the target is missing. Participants
are supposed to return the list of predicted targets only. All datasets are in tab delimited format. The meaning of the attributes and attribute values is given
below. TICTGTS2000.txt Targets for the evaluation set.

fuente: https://archive-beta.ics.uci.edu/ml/datasets/insurance+company+benchmark+coil+2000

liga de descarga: https://archive.ics.uci.edu/ml/machine-learning-databases/tic-mld/tic.tar.gz

**Nota:** En la raíz del repo se localiza un archivo bash que realiza la limpieza y descarga la información.

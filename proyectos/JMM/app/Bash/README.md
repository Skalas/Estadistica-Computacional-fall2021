Descripción de los archivos de carga de datos

**Al iniciar la aplicación es necesario ejecuar el archivo procesa_carga_inicial.sh**
  **Es muy importante previo a cualquier ejecución crear las variable de ambiente PGUSR y PGPASS 
  con el usuario y passwd de la base de datos**
  este proceso realiza la creación de las tablas produccion y predict que se requieren
  descarga los archivos excel del protal 
  junta los 40 archivos descargados en uno solo
  elimina las columnas de los archivos que tienen mas columnas
  selecciona los registros de manzanas
  carga los registros a la base de datos
  
  si se desea hacer alguna etapa por separado se cuenta con los siguentes archivos
  
 

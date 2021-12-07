##### Instalación y carga de paqueterías

# Librerías a utilizar. Si no se tiene alguna, se instala.
pack_u<-c("rstudioapi","readxl","dplyr","knitr","kableExtra","ggplot2","tidyr","leaflet","rgdal","shiny","osrm","rdist")
pack_u_installed<-pack_u %in% installed.packages()
pack_u_uninstalled<-pack_u[pack_u_installed==FALSE]
install.packages(pack_u_uninstalled)
lapply(pack_u, require, character.only = TRUE)

##### Establecer directorio de trabajo y variables de ETL

# Se estable el directorio de trabajo como la carpeta donde se encuentre el archivo .R
setwd(dirname(rstudioapi::getSourceEditorContext()$path)) 

# Variables parámetros para la parte de extracción de información.
dir.archivo<-paste(getwd(),"/","refugios_nayarit.xlsx",sep="")
row.skip<-6
col.names<-c("no","refugio","municipio","direccion","uso_inmueble","servicios","capacidad_personas","latitud","longitud","altitud","responsable","telefono")

##### Extracción de la información a partir del libro de Excel             

# Se buscan todas las hojas posbiles en el excel.
sheets<-excel_sheets(dir.archivo)
for(i in 1:length(sheets))
{
  base<-read_excel(dir.archivo,sheet=sheets[i],skip=row.skip,col_names = FALSE)
  if(i==1){df<-base} else{df<-rbind(df,base)}
}

# Se cargan las bases sin nombre de columna, en este paso se establecen los heads.
names(df)<-col.names

##### Eliminación de registros inválidos

df<-df %>% filter(rowSums(is.na(df))!=ncol(df)-1)

##### Coordenadas geográficas

df<-df %>% 
  
  # Se eliminan registros sin alguna coordenada geográfica
  filter(!(is.na(latitud) | is.na(longitud))) %>%
  
  # Con la función separate se dividen las coordenadas en grados/minutos/segundos a valores numéricos
  separate(latitud,into=c("A","B","C","D"),remove=FALSE,extra="drop",fill="right") %>%
  mutate(D=ifelse(D=="",NA,D)) %>%
  mutate(latitud_val=as.numeric(A)+as.numeric(B)/60+(as.numeric(C)+as.numeric(paste("0",D,sep=".")))/3600) %>%
  select(-A,-B,-C,-D) %>%
  
  separate(longitud,into=c("A","B","C","D"),remove=FALSE,extra="drop",fill="right") %>%
  mutate(D=ifelse(D=="",NA,D)) %>%
  mutate(longitud_val=as.numeric(A)+as.numeric(B)/60+(as.numeric(C)+as.numeric(paste("0",D,sep=".")))/3600) %>%
  select(-A,-B,-C,-D) %>%
  
  # Se detectó que el punto número 434 tiene las coordenadas invertidas
  mutate(latitud1=latitud_val,
         latitud_val=ifelse(no %in% c(434),longitud_val,latitud_val),
         longitud_val=ifelse(no %in% c(434),latitud1,longitud_val)) %>%
  select(-latitud1) %>%
  
  # Se eliminan las coordenadas inválidad después del tratamiento de las variables
  filter(!(is.na(latitud_val) | is.na(longitud_val)))

##### Uso del inmueble

# Se estandarizan tipos de inmuebles que se podrían clasificar como los mismos.
df<-df %>% mutate(uso_inmueble=ifelse(uso_inmueble %in% c("RELIGIOSO","RELIGIOSOS"),"RELIGIOSO",uso_inmueble))
df<-df %>% mutate(uso_inmueble=ifelse(uso_inmueble %in% c("GOBIERNO MUNICIPAL","MUNICIPAL"),"MUNICIPAL",uso_inmueble))

##### Teléfonos

# Se estandarianzan los teléfonos a: 
# teléfono1 // teléfono2 // ... //  teléfonoN
df<-df %>%
  mutate(tel=gsub("-","",telefono)) %>%
  mutate(tel=gsub("\\*","",tel)) %>%
  separate(tel,into=c("A","B","C","D","E","FF","G","H","I","J"),fill="right") %>%
  mutate(A=as.numeric(A),B=as.numeric(B),C=as.numeric(C),D=as.numeric(D),E=as.numeric(E)
         ,FF=as.numeric(FF),G=as.numeric(G),H=as.numeric(H),I=as.numeric(I),J=as.numeric(J)   ) %>%
  mutate(telefonos=paste(A,B,C,D,E,FF,G,H,I,J,sep=" // ") ) %>%
  mutate(telefonos=gsub("NA // ","",telefonos)) %>%
  mutate(telefonos=gsub(" // NA","",telefonos)) %>%
  mutate(telefonos=gsub("NA","",telefonos)) %>%
  select(-A,-B,-C,-D,-E,-FF,-G,-H,-I,-J)

##### Imputación de NA's

# Notar que sólo se eliminaron los registros que no tengan coordenadas geográficas,
# ya que para temas de "negocio" es importante dar coordenadas precisas.

# Se decidió que el resto de campos podrían estar ausentes con el fin de no eliminar puntos
# de refugio sólo porque falte algún otro dato pero si se sepa dónde se encuentra

# Se decidió imputar los valores "character" con el valor "" y los valores numéricos con el
# valor "0". Esto sólo con el fin de no mostrar el valor "NA" en el dashboard final.

df$no[is.na(df$no)]<-0
df$refugio[is.na(df$refugio)]<-""
df$municipio[is.na(df$municipio)]<-""
df$direccion[is.na(df$direccion)]<-""
df$uso_inmueble[is.na(df$uso_inmueble)]<-""
df$servicios[is.na(df$servicios)]<-""
df$capacidad_personas[is.na(df$capacidad_personas)]<-0
df$latitud[is.na(df$latitud)]<-""
df$longitud[is.na(df$longitud)]<-""
df$altitud[is.na(df$altitud)]<-0
df$responsable[is.na(df$responsable)]<-""
df$telefono[is.na(df$telefono)]<-""
df$latitud_val[is.na(df$latitud_val)]<-0
df$longitud_val[is.na(df$longitud_val)]<-0
df$telefonos[is.na(df$telefonos)]<-""



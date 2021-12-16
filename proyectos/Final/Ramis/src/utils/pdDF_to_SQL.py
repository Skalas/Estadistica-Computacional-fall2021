import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database

def get_engine(user, passwd, host, port, db):
    """
    Esta función genera un motor de bsae de datos de PostgreSQL
    Argumentos:
        user, passwd, host, port, db (string): Credenciales e información de la base de datos para la cual se
        quiere hacer la conexión.
    Salidas:
        engine (object): objeto para hacer la conexión con psql
    
    """
    url = f"postgresql://{user}:{passwd}@{host}:{port}/{db}"
    if not database_exists(url):
        create_database(url)
    engine = create_engine(url, pool_size=50, echo=False)
    return engine

# Código utilizado para leer el archivo generado por la limpieza de Bash y pasarlo a una tabla de SQL
df = pd.read_csv("src/temp/data_transfer/ticdata2000_wh.txt", sep = "|")
# Solo se conservan las variables de interés de acuerdo con lo que se menciona en el proyecto reportado
df = df[['MOPLLAAG', 'MINK123M', 'PPERSAUT', 'PWAOREG','PBRAND','APLEZIER','AFIETS','CARAVAN']]
df.columns = [x.lower() for x in df.columns]
# Credenciales del PostgreSQL que se generó con Docker
engine = get_engine("postgres", "postgres", "db", "5432", "postgres")
df.to_sql('variables', con = engine, if_exists = 'replace') # ---> Agregamos esquema clean (revisar)

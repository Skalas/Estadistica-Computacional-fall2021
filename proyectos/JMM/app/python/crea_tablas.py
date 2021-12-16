import psycopg2
import os
# URI = "motor://usuario:password@hostip:port/DB"

database_uri = f'postgresql://{os.environ["PGUSR"]}:{os.environ["PGPASS"]}@0.0.0.0:5432/postgres'
print(database_uri)

conn = psycopg2.connect(database_uri)

cur = conn.cursor()

# TABLA produccion
#cur.execute('DELETE FROM produccion WHERE EXISTS (SELECT * FROM produccion)')
cur.execute('DROP TABLE IF EXISTS produccion')
conn.commit()

cur.execute('create table produccion ( \
Anio varchar, \
Idestado varchar, \
Nomestado varchar, \
Idciclo varchar, \
Nomcicloproductivo varchar, \
Idmodalidad varchar, \
Nommodalidad varchar, \
Idunidadmedida varchar, \
Nomunidad varchar, \
Idcultivo varchar, \
Nomcultivo varchar, \
Sembrada varchar, \
Cosechada varchar, \
Siniestrada varchar, \
Volumenproduccion varchar, \
Rendimiento varchar, \
Precio varchar \
)')
conn.commit()

print("tabla produccion creada exitosamente")
# TABLA modelo

cur.execute('DROP TABLE IF EXISTS modelo')
conn.commit()

cur.execute('CREATE TABLE modelo (mod_pkl BYTEA)')
conn.commit()

print("tabla modelo creada exitosamente")
# TABLA predict

cur.execute('DROP TABLE IF EXISTS predict')
conn.commit()

cur.execute('CREATE TABLE predict ( \
Anio varchar, \
Idestado varchar, \
Nomestado varchar, \
Idciclo varchar, \
Nomcicloproductivo varchar, \
Idmodalidad varchar, \
Nommodalidad varchar, \
Idunidadmedida varchar, \
Nomunidad varchar, \
Idcultivo varchar, \
Nomcultivo varchar, \
Sembrada varchar, \
Cosechada varchar, \
Siniestrada varchar, \
Volumenproduccion varchar, \
Rendimiento varchar, \
Precio varchar \
)')
conn.commit()


cur.close()
print("tabla predict creada exitosamente")



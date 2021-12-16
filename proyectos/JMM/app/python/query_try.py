import psycopg2
import psycopg2.extras
import json
import pandas as pd
import os

# URI = "motor://usuario:password@hostip:port/DB"

database_uri = f'postgresql://{os.environ["PGUSR"]}:{os.environ["PGPASS"]}@0.0.0.0:5432/postgres'
#print(database_uri)

conn = psycopg2.connect(database_uri)

cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
cur.execute("select * from produccion")
results = cur.fetchall()
cur.close()

#print(json.dumps([x._asdict() for x in results], default=str))
print(pd.DataFrame(results))

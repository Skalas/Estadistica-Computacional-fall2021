import psycopg2
import os
# URI = "motor://usuario:password@hostip:port/DB"

database_uri = f'postgresql://{os.environ["PGUSR"]}:{os.environ["PGPASS"]}@0.0.0.0:5432/postgres'
print(database_uri)

conn = psycopg2.connect(database_uri)

cur = conn.cursor()
cur.execute('create table users (id serial Primary key, name varchar, lastname varchar, age integer)')
cur.execute('insert into users (name, lastname,age) values (%s, %s, %s)', ('Miguel', 'Escalante', '32'))
conn.commit()

cur.execute('select * from users;')

cur.fetchone()
cur.fetchall()

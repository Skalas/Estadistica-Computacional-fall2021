import psycopg2


database_uri = "postgresql://postgres:postgres@0.0.0.0:5432/postgres"
conn = psycopg2.connect(database_uri)
cur = conn.cursor()
cur.execute('drop table users;')
cur.execute('create table users (id serial Primary key, name varchar, lastname varchar, age integer)')
cur.execute('insert into users (name, lastname,age) values (%s, %s, %s)', ('Miguel', 'Escalante', '32'))
conn.commit()

cur.execute('select * from users;')
cur.fetchone()

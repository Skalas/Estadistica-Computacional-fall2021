curl -X POST -H "Content-Type: application/json"\
     -d '{"name":"Pedro", "lastname":"Pérez", "age":33}'\
     0.0.0.0:5000/user

curl -X DELETE 0.0.0.0:5000/user?id=2

curl -X PATCH -H "Content-Type: application/json"\
     -d '{"name":"Pedru", "lastname":"Péres", "age":44}'\
     0.0.0.0:5000/user?id=4

curl -X POST -H "Content-Type: application/json"\
     -d '[{"name":"Pedro", "lastname":"Pérez", "age":33},
     	  {"name":"Lucía", "lastname":"Juarez", "age":23}]'\
     0.0.0.0:5000/users

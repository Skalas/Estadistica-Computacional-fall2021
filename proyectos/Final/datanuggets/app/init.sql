--Creamos tabla para los datos originales de entrenamiento
create table train_table (id serial Primary key, ingreso float, internet integer, edad integer, 
hrs_trab float, educacion integer, num_autos integer, num_compu integer, num_cuartos integer, 
seguro_med integer, mujer integer, resid integer);


--Creamos tabla donde se meten los datos nuevos 
create table train_new (id serial Primary key, ingreso float, internet integer, edad integer, 
hrs_trab float, educacion integer, num_autos integer, num_compu integer, num_cuartos integer, 
seguro_med integer, mujer integer, resid integer);

--Creamos tabla donde se registran los resultados
create table train_res (id serial Primary key, ingreso_estimado float, internet integer, edad integer, 
hrs_trab float, educacion integer, num_autos integer, num_compu integer, num_cuartos integer, 
seguro_med integer, mujer integer, resid integer);

--Cargamos los datos en la tabla inicial que se llama train_table 
COPY train_table (ingreso, internet, edad, hrs_trab, educacion, num_autos, num_compu, num_cuartos,seguro_med,mujer,resid) FROM 
'/var/lib/postgresql/csvs/df.csv' DELIMITER ',' CSV HEADER;
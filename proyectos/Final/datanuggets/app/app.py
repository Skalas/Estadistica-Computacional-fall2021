# Importar librerias
from flask import Flask, jsonify, request
import pickle
import numpy as np
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
import json, sys
from psycopg2 import connect, Error
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingRegressor


# Servidor
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False #Para conservar el orden del json

#Conexion a la base de datos
try:
    # Declaramos una nueva conexion
    conn = connect(
        dbname = "postgres",
        user = "postgres",
        host = "db",
        password = "postgres",
        # attempt to connect for 3 seconds then raise exception
        connect_timeout = 3
    )
    conn.autocommit = True
    cur = conn.cursor()
    #cur.close()
    print ("\ncreated cursor object:", cur)
    

except (Exception, Error) as err:
    print ("\npsycopg2 connect error:", err)
    conn = None
    cur = None


#PRESENTACION EQUIPO
# Metodo GET para presentar al equipo
@app.route('/presentacion/', methods=['GET'])
def presentacion():
    return jsonify({'Bienvenido':'somos el equipo de datanuggets, conoce a nuestros integrantes',
                    'Integrante 1':'Monica Altagracia Garcia',
                    'Integrante 2': 'Arturo Soberon',
                    'Integrante 3': 'Rodrigo Juarez',
                    'Integrante 4': 'Jorge Garcia Durante'})

#CONSULTAR, INSERTAR, BORRAR O ACTUALIZAR NUEVOS DATOS
@app.route('/new_data/', methods=['GET','POST','DELETE','PATCH'])
def nuevos_datos():
    #Consulta algun rango de datos de la tabla de acuerdo al los id de los usuarios
    if request.method == 'GET':
        cur = conn.cursor()  
        user_id = np.array([list(x.values()) for x in request.json])
        try:
            cur.execute(f"SELECT * FROM train_new WHERE id >= {user_id[0][0].item()} AND id <= {user_id[0][1].item()}")
            temp = cur.fetchall()
            col_names = []
            for elt in cur.description:
                col_names.append(elt[0])
            resultado = pd.DataFrame(temp, columns=col_names)
            cur.close()
            return(jsonify(resultado.to_dict(orient='records')))
            
        except:
            cur.close()
            return(jsonify({'Message': 'Por favor intenta de nuevo'}))


    #Insetar nuevos datos, pueden ser multiples datos 
    if request.method == 'POST':
        cur = conn.cursor()
        new_people = request.json
        user_list = [(client["ingreso"], client["internet"], client["edad"], 
                     client["hrs_trab"], client["educacion"], client["num_autos"],
                     client["num_compu"], client["num_cuartos"], client["seguro_med"],
                     client["mujer"], client["resid"]) for client in new_people]
        sql = "INSERT INTO train_new (ingreso,internet,edad,hrs_trab,educacion,num_autos,num_compu,num_cuartos,seguro_med,mujer,resid) \
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        cur.executemany(sql, user_list)
        conn.commit()
        cur.close()
        return(jsonify({'Message':'Datos ingresados'}))
    
    #Borrar alguno de los datos ingresados 
    if request.method == 'DELETE':
        cur = conn.cursor()
        user_id = request.args.get("id")
        cur.execute(f"DELETE FROM train_new WHERE id={user_id}")
        conn.commit()
        cur.close()
        return(jsonify({'Message':'Dato eliminado'}))

    #Actualiza algún dato existente 
    if request.method == 'PATCH':
        X = np.array([list(x.values()) for x in request.json]) 
        cur = conn.cursor()
        cur.execute(f'UPDATE train_new SET ingreso = {X[0][1].item()}, internet = {X[0][2].item()}, edad = {X[0][3].item()}, \
                    hrs_trab = {X[0][4].item()}, educacion = {X[0][5].item()}, num_autos = {X[0][6].item()}, num_compu = {X[0][7].item()}, \
                    num_cuartos = {X[0][8].item()}, seguro_med = {X[0][9].item()}, mujer = {X[0][10].item()}, resid = {X[0][11].item()} \
                    WHERE id = {X[0][0].item()}')
        conn.commit()
        cur.close()
        return(jsonify({'Message':'Datos actualizados'}))

#HACER UNA PREDICCION
# Método POST para predecir ingresos solicitados de acuerdo al modelo precargado o actualizado
# Es posible obtener el resultado de mas de un registo 
@app.route('/predict/', methods=['POST'])
def predict():
    # Leemos el modelo
    m = pickle.load(open('/app/model/gbr.pkl', 'rb'))
    # Request
    X = np.array([list(x.values()) for x in request.json])
    # Prediccion
    y_hat = list(m.predict(X))
    #df_pred = pd.DataFrame(y_hat)

    #Insertamos el resultado obtenido con las catacteristicas con las que se hizo la prediccion
    #Se establece una conexion
    engine = create_engine('postgresql://postgres:postgres@db:5432/postgres')
    new_res = request.json
    user_list = [(client["internet"], client["edad"], 
                    client["hrs_trab"], client["educacion"], client["num_autos"],
                    client["num_compu"], client["num_cuartos"], client["seguro_med"],
                    client["mujer"], client["resid"]) for client in new_res]
    df_list = pd.DataFrame(user_list)
    df_list["10"] = y_hat
    cols = list(df_list.columns)
    cols = [cols[-1]] + cols[:-1]
    df_list = df_list[cols]
    df_list.reset_index(drop=True, inplace=True)
    df_list.columns = ['ingreso_estimado', 'internet', 'edad', 'hrs_trab', 'educacion', 'num_autos', 'num_compu', 'num_cuartos', 'seguro_med', 'mujer', 'resid']
    df_list.to_sql('train_res', engine, if_exists='append', index=False)
    mensaje = {'Message':'Los resultados de la prediccion son:'}
    return(jsonify(mensaje, df_list.to_dict(orient='records')))


#REENTRENAR EL MODELO 
# Método POST para recibir nuevos registros, agregarlos a SQL y recalibrar el modelo
@app.route('/recalibrate/', methods=['GET'])
def recalibrate():
    cur = conn.cursor()
    #Lectura de los datos
    try:
        cur.execute("SELECT * FROM train_table \
                     UNION ALL \
                     SELECT * FROM train_new")
        df = pd.DataFrame(cur.fetchall())
    except:
        print("No lei los datos")

    #Dividimos los datos 
    X_train, X_test, y_train, y_test = train_test_split(df.iloc[:,2:12], df.iloc[:,1], 
    test_size=0.1, random_state=123)
    
    # Hiperparámetros
    gb = GradientBoostingRegressor(loss='ls', learning_rate=0.03, n_estimators=300, max_depth=3, random_state=123)
    
    #Reentrenamos el modelo 
    gb.fit(X_train, y_train)
    
    #Regresa nuevo score
    print(gb.score(X_train, y_train))
    
    #Exportar modelo re-entrenado
    pickle.dump(gb, open('/app/model/gbr.pkl', 'wb'))

    mensaje = {'Message':'El modelo ha sido reentrenado'}
    return jsonify(mensaje)


#REGRESAR AL MODELO ORIGINAL
#El siguiente código nos regresa al modelo original

@app.route('/reset/', methods = ['GET'])
def modelo_orig():
    #Elegimos los datos originales de nuesta base de datos
    try:
        cur.execute("SELECT * FROM train_table")
        df_orig = pd.DataFrame(cur.fetchall()) #Retornamos al dato original
    except:
        print("No se pudo leer los datos")
    
    #Dividimos los datos 
    X_train, X_test, y_train, y_test = train_test_split(df_orig.iloc[:,2:12], df_orig.iloc[:,1], 
    test_size=0.1, random_state=123)
    
    # Hiperparámetros
    gb = GradientBoostingRegressor(loss='ls', learning_rate=0.03, n_estimators=300, max_depth=3, random_state=123)
    
    #Reentrenamos el modelo 
    gb.fit(X_train, y_train)
    
    #Exportar modelo re-entrenado
    pickle.dump(gb, open('/app/model/gbr.pkl', 'wb'))

    #Regresamos mensaje
    return({'Excelente noticia':'Se entreno el modelo con el dato original nuevamente, perdice tu ingreso :D!!!'})


# Correr app cuando se ejecuta el script
if __name__ == '__main__':
    app.run(host = '0.0.0.0', debug=True ,port=4000)
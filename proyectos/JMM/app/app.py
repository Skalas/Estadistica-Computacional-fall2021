from flask import Flask, request , render_template
import psycopg2
import psycopg2.extras
import json
#import pandas as pd
from modelo.model_class import InitialModel
from modelo.model_class import Predictions
import os


database_uri = f'postgresql://{os.environ["PGUSR"]}:{os.environ["PGPASS"]}@db:5432/postgres'

app = Flask(__name__)
conn = psycopg2.connect(database_uri)

@app.route("/")
def index(): 
    return render_template('index.html')        
        
@app.route("/carga", methods=["POST", "GET", "DELETE", "PATCH"])
def carga():
    if request.method == "GET":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select * from produccion")
        results = cur.fetchall()
        cur.close()
        return json.dumps([x._asdict() for x in results], default=str)
    if request.method == "POST":
        cur = conn.cursor()
        carga = request.json
        carga_list = [(produccion["Anio"], produccion["Idestado"], produccion["Nomestado"], produccion["Idciclo"], produccion["Nomcicloproductivo"], produccion["Idmodalidad"], produccion["Nommodalidad"], produccion["Idunidadmedida"], produccion["Nomunidad"], produccion["Idcultivo"], produccion["Nomcultivo"], produccion["Sembrada"], produccion["Cosechada"], produccion["Siniestrada"], produccion["Volumenproduccion"], produccion["Rendimiento"], produccion["Precio"] ) for produccion in carga]
        cur.executemany(
            "insert into produccion (Anio, Idestado, Nomestado, Idciclo, Nomcicloproductivo, Idmodalidad, Nommodalidad, Idunidadmedida,Nomunidad, Idcultivo, Nomcultivo, Sembrada, Cosechada,Siniestrada, Volumenproduccion, Rendimiento, Precio) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", carga_list
        )
        conn.commit() 
        cur.close()
        return "ok "
    if request.method == "DELETE":
        cur = conn.cursor()
        cur.execute("delete from produccion")
        conn.commit()
        cur.close()
        return "todos los datos de la tabla produccion fueron borrados"
  

@app.route("/modela", methods = ["FIT"])
def corre_modelo():
    if request.method == "FIT":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select * from produccion")
        results = cur.fetchall()
        cur.close()
        im = InitialModel()
        pkl =  im.ajusta_modelo(results)
        
        cur = conn.cursor()
        cur.execute('INSERT INTO modelo (mod_pkl) VALUES (%s)', (psycopg2.Binary(pkl), ))
        conn.commit()
        cur.close()
        
        return "el modelo se guardo correctamente"
        #return f"score de ajuste es {path}"

@app.route("/carga_pred", methods=["POST", "GET", "DELETE", "PATCH"])
def carga_pred():
    if request.method == "GET":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select * from predict")
        results = cur.fetchall()
        cur.close()
        return json.dumps([x._asdict() for x in results], default=str)
    if request.method == "POST":
        cur = conn.cursor()
        carga_pred = request.json
        carga_list = [(predict["Anio"], predict["Idestado"], predict["Nomestado"], predict["Idciclo"], predict["Nomcicloproductivo"], predict["Idmodalidad"], predict["Nommodalidad"], predict["Idunidadmedida"], predict["Nomunidad"], predict["Idcultivo"], predict["Nomcultivo"], predict["Sembrada"], predict["Cosechada"], predict["Siniestrada"], predict["Volumenproduccion"], predict["Rendimiento"], predict["Precio"] ) for predict in carga_pred]
        cur.executemany(
            "insert into predict (Anio, Idestado, Nomestado, Idciclo, Nomcicloproductivo, Idmodalidad, Nommodalidad, Idunidadmedida,Nomunidad, Idcultivo, Nomcultivo, Sembrada, Cosechada,Siniestrada, Volumenproduccion, Rendimiento, Precio) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", carga_list
        )
        conn.commit() 
        cur.close()
        return "ok "
    if request.method == "DELETE":
        cur = conn.cursor()
        cur.execute("delete from predict")
        conn.commit()
        cur.close()
        return "todos los datos de la tabla predict fueron borrados"
     
               
@app.route("/predice", methods=["GET"])
def predice():             
    if request.method == "GET":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select mod_pkl from modelo")
        mod_pkl = cur.fetchone()
        cur.close()
        
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select * from predict")
        results = cur.fetchall()
        cur.close()
        
        prd = Predictions()
        preds = prd.predict(mod_pkl, results)
        
        return json.dumps([x for x in preds], default=str)              
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8080)

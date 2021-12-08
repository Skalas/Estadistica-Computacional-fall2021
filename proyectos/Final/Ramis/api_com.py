from flask import Flask, request
import psycopg2
import psycopg2.extras
import json
import os
#import flask
import pickle as pkl
import sklearn
import numpy as np
import pandas as pd
database_uri = "postgresql://postgres:postgres@db:5432/postgres"
app = Flask(__name__)
conn = psycopg2.connect(database_uri)
@app.route("/")
def home():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select * from variables limit 10;")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)
@app.route("/user", methods=["POST", "GET"])
def user():
    if request.method == "GET":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        user_id = request.args.get("id")
        cur.execute(f"select * from users where id={user_id}")
        results = cur.fetchone()
        cur.close()
        return json.dumps(results._asdict(), default=str)
    if request.method == "POST":
        user = request.json
        cur = conn.cursor()
        cur.execute(
            "insert into users (name, lastname, age) values (%s, %s, %s)",
            (user["name"], user["lastname"], user["age"]),
        )
        conn.commit()
        cur.execute("SELECT LASTVAL()")
        user_id = cur.fetchone()[0]
        cur.close()
        return json.dumps({"user_id": user_id})
@app.route("/users", methods=["POST", "GET"])
def users():
    if request.method == "GET":
        modelo, precision, recall = utils.modelado(1)
        return "El modelo se ha reentrenado adecuadamente"
    if request.method == "POST":
        inputs = request.json
        predecir = inputs["predecir"]
        users_list = [[predecir["mopllaag"], predecir["mink123m"],predecir["ppersaut"],
        predecir["pwaoreg"], predecir["pbrand"],predecir["aplezier"], predecir["afiets"]]]
        with open("/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct/src/temp/trained_models/modelo_lr_pkl", "rb") as f:
            model_loaded = pkl.load(f)
        pred = model_loaded.predict(users_list)
    return json.dumps({"valor_de_prediccion": pred[0].astype(str)})
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8080)

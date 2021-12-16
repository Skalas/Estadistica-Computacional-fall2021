from flask import Flask, request
import psycopg2
import psycopg2.extras
import json
import pandas as pd
from utils import modeling, prediction

database_uri = "postgresql://postgres:pokemon@db:5432/postgres"
#Regresar a db cuando se corra con docker-compose

app = Flask(__name__)
conn = psycopg2.connect(database_uri)
#global m=1  

@app.route("/")
def home():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("SELECT * FROM pokemon_ limit 3;")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/modelo")
def modelo():
    numclusters = request.args.get("numeroclusters")
    cal = request.args.get("calibracion")
    if cal == "True":
        modeling(int(numclusters),True)
        return ("Modelo entrenado correctamente")
    else:
        results = modeling(int(numclusters),False)
        return results.to_json(orient="records")

@app.route("/pokemons", methods=["POST"])
def pokemons():
    if request.method == "POST":
        cur = conn.cursor()
        pokemons = request.json
        pokemons_list = [(pokemon["Abilities"],pokemon["Against_Bug"],pokemon["Against_Dark"],pokemon["Against_Dragon"],pokemon["Against_Electric"],pokemon["Against_Fairy"],pokemon["Against_Fight"],pokemon["Against_Fire"],pokemon["Against_Flying"],pokemon["Against_Ghost"],pokemon["Against_Grass"],pokemon["Against_Ground"],pokemon["Against_Ice"],pokemon["Against_Normal"],pokemon["Against_Poison"],pokemon["Against_Psychic"],pokemon["Against_Rock"],pokemon["Against_Steel"],pokemon["Against_Water"],pokemon["Attack"],pokemon["Base_Egg_Steps"],pokemon["Base_Happiness"],pokemon["Base_Total"],pokemon["Capture_Rate"],pokemon["Classfication"],pokemon["Defense"],pokemon["Experience_Growth"],pokemon["Height_M"],pokemon["Hp"],pokemon["Japanese_Name"],pokemon["Name"],pokemon["Percentage_Male"],pokemon["Pokedex_Number"],pokemon["Sp_Attack"],pokemon["Sp_Defense"],pokemon["Speed"],pokemon["Type1"],pokemon["Type2"],pokemon["Weight_Kg"],pokemon["Generation"],pokemon["Is_Legendary"]) for pokemon in pokemons]
        cur.executemany(
            "insert into pokemon_ (Abilities, Against_Bug, Against_Dark, Against_Dragon, Against_Electric, Against_Fairy, Against_Fight, Against_Fire, Against_Flying, Against_Ghost, Against_Grass, Against_Ground, Against_Ice, Against_Normal, Against_Poison, Against_Psychic, Against_Rock, Against_Steel, Against_Water, Attack, Base_Egg_Steps, Base_Happiness, Base_Total, Capture_Rate, Classfication, Defense, Experience_Growth, Height_M, Hp, Japanese_Name, Name, Percentage_Male, Pokedex_Number, Sp_Attack, Sp_Defense, Speed, Type1, Type2, Weight_Kg, Generation, Is_Legendary) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", pokemons_list
        )
        conn.commit()
        cur.close()
        return "Insercion de datos nuevos de manera correcta"

@app.route("/predictions", methods=["POST"])
def predictions():
    if request.method == "POST":
        cur = conn.cursor()
        pokemons = request.json
#        pokemons_aux = json.loads(pokemons)
        df_pokemons = pd.DataFrame.from_dict(pokemons)
        df_pokemons.columns = df_pokemons.columns.str.lower()
        n_prediction = df_pokemons.shape[0]
#        pokemons_list = [(pokemon["Abilities"],pokemon["Against_Bug"],pokemon["Against_Dark"],pokemon["Against_Dragon"],pokemon["Against_Electric"],pokemon["Against_Fairy"],pokemon["Against_Fight"],pokemon["Against_Fire"],pokemon["Against_Flying"],pokemon["Against_Ghost"],pokemon["Against_Grass"],pokemon["Against_Ground"],pokemon["Against_Ice"],pokemon["Against_Normal"],pokemon["Against_Poison"],pokemon["Against_Psychic"],pokemon["Against_Rock"],pokemon["Against_Steel"],pokemon["Against_Water"],pokemon["Attack"],pokemon["Base_Egg_Steps"],pokemon["Base_Happiness"],pokemon["Base_Total"],pokemon["Capture_Rate"],pokemon["Classfication"],pokemon["Defense"],pokemon["Experience_Growth"],pokemon["Height_M"],pokemon["Hp"],pokemon["Japanese_Name"],pokemon["Name"],pokemon["Percentage_Male"],pokemon["Pokedex_Number"],pokemon["Sp_Attack"],pokemon["Sp_Defense"],pokemon["Speed"],pokemon["Type1"],pokemon["Type2"],pokemon["Weight_Kg"],pokemon["Generation"],pokemon["Is_Legendary"]) for pokemon in pokemons]
        cur.close()
        results = prediction(7,df_pokemons,n_prediction)
        return results.to_json(orient="records")
#        return "Ya casi"
        
if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8080)
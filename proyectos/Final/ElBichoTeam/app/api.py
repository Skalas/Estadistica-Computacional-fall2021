from flask import Flask, request
import psycopg2
import numpy as np
import json
import pandas as pd
import psycopg2.extras
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from sklearn import metrics

database_FIFA = "postgresql://postgres:postgres@db:5432/postgres"
app = Flask(__name__)
conn = psycopg2.connect(database_FIFA)


@app.route("/top10")
def home():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select name, nationality, club, overall from fifa21 limit 10;")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/top10mexico")
def mexico():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select name, nationality, club, overall from fifa21 where nationality = 'mexico' limit 23;")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/RealMadrid")
def madrid():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select name, nationality, club, overall from fifa21 where club = 'Real Madrid';")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/overall")
def overall():
    over = request.args.get("over")
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute(f"select name, club, age, value_eur, wage from fifa21 where overall = {over} ")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/wageageover")
def wageageover():
    wage = request.args.get("wage")
    age = request.args.get("age")
    over = request.args.get("over")
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute(f"select name, club, age, value_eur, wage from fifa21 where overall >= {over} and wage < {wage} and age <= {age}")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/nation")
def nation():
    nation = request.args.get("nation")
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute(f"post name, club, age, value_eur, wage from fifa21 where nationality = '{nation}' limit 10 ")
    results = cur.fetchall()
    cur.close()
    return json.dumps([x._asdict() for x in results], default=str)

@app.route("/addingplayer")
def addingplayer():
    sofifa_id=request.args.get("sofifa_id")
    long_name=request.args.get("long_name")
    age=request.args.get("age")
    height_cm=request.args.get("height_cm")
    weight_kg=request.args.get("weight_kg")
    nationality=request.args.get("nationality")
    club_name=request.args.get("club_name")
    league_name=request.args.get("league_name")
    overall=request.args.get("overall")
    value_eur=request.args.get("value_eur")
    wage_eur=request.args.get("wage_eur")
    player_positions=request.args.get("player_positions")
    international_reputation=request.args.get("international_reputation")
    weak_foot=request.args.get("weak_foot")
    skill_moves=request.args.get("skill_moves")
    work_rate=request.args.get("work_rate")
    team_position=request.args.get("team_position")
    team_jersey_number=request.args.get("team_jersey_number")
    joined=request.args.get("joined")
    contract_valid_until=request.args.get("contract_valid_until")
    pace=request.args.get("pace")
    shooting=request.args.get("shooting")
    passing=request.args.get("passing")
    dribbling=request.args.get("dribbling")
    defending=request.args.get("defending")
    physic=request.args.get("physic")
    attacking_crossing=request.args.get("attacking_crossing")
    attacking_heading_accuracy=request.args.get("attacking_heading_accuracy")
    attacking_volleys=request.args.get("attacking_volleys")
    skill_curve=request.args.get("skill_curve")
    skill_fk_accuracy=request.args.get("skill_fk_accuracy")
    skill_long_passing=request.args.get("skill_long_passing")
    movement_agility=request.args.get("movement_agility")
    movement_reactions=request.args.get("movement_reactions")
    movement_balance=request.args.get("movement_balance")
    power_jumping=request.args.get("power_jumping")
    power_stamina=request.args.get("power_stamina")
    power_strength=request.args.get("power_strength")
    mentality_aggression=request.args.get("mentality_aggression")
    mentality_vision=request.args.get("mentality_vision")
    mentality_penalties=request.args.get("mentality_penalties")
    mentality_composure=request.args.get("mentality_composure")
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("insert into mytable values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ",
    (sofifa_id,long_name,age,height_cm,weight_kg,nationality,club_name,league_name,overall,value_eur,wage_eur,player_positions,international_reputation,weak_foot,skill_moves,work_rate,team_position,team_jersey_number,joined,contract_valid_until,pace,shooting,passing,dribbling,defending,physic,attacking_crossing,attacking_heading_accuracy,attacking_volleys,skill_curve,skill_fk_accuracy,skill_long_passing,movement_agility,movement_reactions,movement_balance,power_jumping,power_stamina,power_strength,mentality_aggression,mentality_vision,mentality_penalties,mentality_composure),
    )
    conn.commit()
    cur.close()

    datos_last_value = pd.read_sql_query('select sofifa_id, pace, shoooting, passing, dribbling, defending, physic, attacking_crossing, position from fifa21', con=psycopg2.connect('postgresql://postgres:postgres@db:5432/postgres'))
    last_value=datos_last_value['sofifa_id'].max()
    return 'El último sofifa_id es: ' + str(last_value)

@app.route("/model")
def model ():
    pace = request.args.get("pace")
    shooting = request.args.get("shooting")
    passing = request.args.get("passing")
    dribbling = request.args.get("dribbling")
    defending = request.args.get("defending")
    physic = request.args.get("physic")
    attacking =request.args.get('attacking')
    datos_model = pd.read_sql_query('select pace, shoooting, passing, dribbling, defending, physic, attacking_crossing, position from fifa21', con=psycopg2.connect('postgresql://postgres:postgres@db:5432/postgres'))
    datos_model.replace('LB',0,inplace=True)
    datos_model.replace('CF',1,inplace=True)
    datos_model.replace('LM',2,inplace=True)
    datos_model.replace('CM',3,inplace=True)
    datos_model.replace('RM',4,inplace=True)
    datos_model.replace('CB',5,inplace=True)
    datos_model.replace('RB',6,inplace=True)
    neigh=KNeighborsClassifier(n_neighbors=7)
    datos_model=datos_model[datos_model['position']!='GK']
    datos_model=datos_model[datos_model['position']!='RES']
    datos_model=datos_model[datos_model['position']!='SUB']
    datos_model['pace']=datos_model['pace'].astype(int)
    datos_model['shoooting']=datos_model['shoooting'].astype(int)
    datos_model['passing']=datos_model['passing'].astype(int)
    datos_model['dribbling']=datos_model['dribbling'].astype(int)
    datos_model['defending']=datos_model['defending'].astype(int)
    datos_model['physic']=datos_model['physic'].astype(int)
    datos_model=datos_model.dropna()
    y=datos_model.position.values
    y=y.astype(int)
    pace=int(pace)
    shooting=int(shooting)
    passing=int(passing)
    dribbling=int(dribbling)
    defending=int(defending)
    physic=int(physic)
    attacking=int(attacking)
    c=[[pace], [shooting], [passing], [dribbling], [defending], [physic], [attacking]]
    j=np.array(c)
    p=j.reshape((1,7))
    x=datos_model.drop(columns={"position"})
    X_train, X_test, y_train, y_test=train_test_split(x,y,test_size=.25,random_state=516)
    neigh.fit(X_train, y_train)
    y_pred=neigh.predict(p)
    if (y_pred==0):
        nombre="Tu jugador es Defensa Izquierdo (LB)"
    elif (y_pred==1):
        nombre="Tu jugador es Centro Delantero (CF)"
    elif (y_pred==2):
        nombre="Tu jugador es Mediocampista Izquierdo (LM)"
    elif (y_pred==3):
        nombre="Tu jugador es Mediocampista Central (CM)"
    elif (y_pred==4):
        nombre="Tu jugador es Mediocampista Derecho (RM)"
    elif (y_pred==5):
        nombre="Tu jugador es Defensa Central (CB)"
    else:
        nombre="Tu jugador es Defensa Derecho (RB)"

    return nombre


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True, port=8080)

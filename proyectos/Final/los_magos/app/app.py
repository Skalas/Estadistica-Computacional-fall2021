from flask import Flask, request, render_template, session, redirect, Response
import psycopg2
import psycopg2.extras
import json
import numpy as np
import pandas as pd
import time

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import log_loss
from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import RepeatedKFold
from sklearn.inspection import permutation_importance
import multiprocessing

import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.image as mpimg

import random
import io
import os
from pathlib import Path
import shutil
from datetime import datetime
from joblib import dump
from joblib import load

time.sleep(10)

database_uri = "postgresql://postgres:postgres@db:5432/postgres"

app = Flask(__name__)
conn = psycopg2.connect(database_uri)

month_dict = {"01" : 'Enero',
              "02" : 'Febrero',
              "03" : 'Marzo',
              "04" : 'Abril',
              "05" : 'Mayo',
              "06" : 'Junio',
              "07" : 'Julio',
              "08" : 'Agosto',
              "09" : 'Septiembre',
              "10" : 'Octubre',
              "11" : 'Noviembre',
              "12" : 'Diciembre'}
def format_file(file):
    year = file.split('_')[-6]
    month = file.split('_')[-5]
    day = file.split('_')[-4]
    hour = file.split('_')[-3]
    minute = file.split('_')[-2]
    second = file.split('_')[-1][:2]
    
    return month_dict[month] + ' ' + day + ', ' + year + ' (' + hour + 'H:' + minute + 'M::' + second + 'S)'



@app.route("/")
def home():
    return render_template('index.html')

@app.route("/user", methods=["POST", "GET", "DELETE", "PATCH"])
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
        cur.execute("insert into users (gender, age, hypertension, heart_disease, ever_married, Residence_type , avg_glucose_level, bmi, smoking_status, stroke) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" ,\
                   (user["gender"], user["age"], user["hypertension"], user["heart_disease"], user["ever_married"], user["Residence_type"], user["avg_glucose_level"], user["bmi"], user["smoking_status"], user["stroke"]),
                   )

        conn.commit()
        cur.execute("SELECT LASTVAL()")
        user_id = cur.fetchone()[0]
        cur.close()
        return json.dumps({"new_user": 'Se registro un nuevo usuario'})

    if request.method == "DELETE":
        cur = conn.cursor()
        user_id = request.args.get("id")
        cur.execute(f"delete from users where id={user_id}")
        conn.commit()
        cur.close()
        return json.dumps({"user_id": user_id})

    if request.method == "PATCH":
        user = request.json
        cur = conn.cursor()
        user_id = request.args.get("id")
        cur.execute("update users set (gender, age, hypertension, heart_disease, ever_married, Residence_type , avg_glucose_level, bmi, smoking_status, stroke) = (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) where id=%s" ,\
                   (user["gender"], user["age"], user["hypertension"], user["heart_disease"], user["ever_married"], user["Residence_type"], user["avg_glucose_level"], user["bmi"], user["smoking_status"], user["stroke"], user_id),
                   )
        conn.commit()
        cur.close()
        return json.dumps({"user_id": user_id})

@app.route("/users", methods=["POST", "GET", "DELETE"])
def users():
    if request.method == "GET":
        cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("select * from users")
        results = cur.fetchall()
        cur.close()
        return json.dumps([x._asdict() for x in results], default=str)
    
    if request.method == "POST":
        cur = conn.cursor()
        users = request.json
        users_list = [(user["gender"], user["age"], user["hypertension"], user["heart_disease"], user["ever_married"], user["Residence_type"], user["avg_glucose_level"], user["bmi"], user["smoking_status"], user["stroke"]) for user in users]
        cur.executemany(
            "insert into users (gender, age, hypertension, heart_disease, ever_married, Residence_type , avg_glucose_level, bmi, smoking_status, stroke) values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", users_list
        )
        conn.commit()
        cur.close()
        return "Correct!!"
    if request.method == "DELETE":
        users = request.json
        cur = conn.cursor()
        users_list = [(user,) for user in users["id"]]
        cur.executemany("delete from users where id=%s",  users_list)
        conn.commit()
        cur.close()
        return json.dumps({"mensaje": 'Se borraron correctamente'})

@app.route("/train_model")
def train_model():

    ### Leemos el grid desde el json. Si no le pasamos nada, ocupamos un default básico.
    param_grid = request.json 
    if param_grid is None:
        param_grid = param_grid = {'n_estimators': [120], 'max_features': [5]}

    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select * from users")
    results = cur.fetchall()    
    cur.close()
    print("Data has been retreived. Model is being trained...")
    all_data = pd.DataFrame(results, columns = ['id', 'gender', 'age', 'hypertension', 'heart_disease', \
            'ever_married', 'Residence_type', 'avg_glucose_level', 'bmi', 'smoking_status', 'stroke'])
    all_data.drop('id', 1, inplace = True)

    X_train, X_test, y_train, y_test = train_test_split(all_data.drop(columns = "stroke"),
                                                        all_data['stroke'],
                                                        random_state = 203129)

    grid = GridSearchCV(
            estimator  = RandomForestClassifier(random_state = 203129),
            param_grid = param_grid,
            scoring    = 'neg_log_loss',
            n_jobs     = multiprocessing.cpu_count() - 1,
            cv         = RepeatedKFold(n_splits=5, n_repeats=3, random_state=203129), 
            refit      = True,
            verbose    = 0,
            return_train_score = True
        )

    ### Ajustamos la Grid y recuperamos el mejor modelo
    grid.fit(X = X_train, y = y_train)
    modelo_final = grid.best_estimator_

    ### El ID será generado a partir de la fecha y hora de creación
    id_model = str(datetime.now())[:-7].replace('-', '_').replace(' ', '_').replace(':', '_')

    ### Guardamos el modelo en carpetas locales dentro de Docker
    dump(modelo_final, filename = f"/app/modelos_locales/random_forest_{id_model}.joblib")    

    ### Resultados
    ## Gráficas de Importancia por Permutaciones
    importancia = permutation_importance(modelo_final, X_train, y_train, n_repeats = 5, scoring = 'neg_log_loss', 
                                         n_jobs = multiprocessing.cpu_count() - 1, random_state = 203129)

    df_importancia = pd.DataFrame({k: importancia[k] for k in ['importances_mean', 'importances_std']})
    df_importancia['variable'] = X_train.columns
    df_importancia.columns = ['media_importancias', 'std_importancias', 'variable']
    df_importancia = df_importancia.sort_values('media_importancias', ascending=True)

    fig, ax = plt.subplots(figsize=(8, 6))

    ax.plot(df_importancia['media_importancias'],  df_importancia['variable'], 
            marker="+", markersize = 8, linestyle="", alpha=0.8, color="black")

    ax.barh(df_importancia['variable'], df_importancia['media_importancias'], 
            xerr=df_importancia['std_importancias'], align='center', alpha=0)

    ax.set_title('Importancia', fontsize = 16)
    ax.tick_params(labelsize = 12)
    plt.savefig(f"/app/modelos_locales/random_forest_importancia_{id_model}.png", dpi=200, bbox_inches='tight')
    plt.close()

    ## Parámetros y Resultados
    predicciones_train = modelo_final.predict(X = X_train)
    logloss_train = log_loss(y_true  = y_train, y_pred  = predicciones_train)

    predicciones_test = modelo_final.predict(X = X_test)
    logloss_test = log_loss(y_true  = y_test, y_pred  = predicciones_test)

    results = pd.concat([pd.Series({'R^2 Train': modelo_final.score(X_train, y_train),
                                    'R^2 Test': modelo_final.score(X_test, y_test),
                                    'Logloss Train': logloss_train,
                                    'Logloss Test': logloss_test}),
                        pd.Series(modelo_final.get_params())])

    results.to_csv(f"/app/modelos_locales/random_forest_resultados_{id_model}.csv")

    return json.dumps({"message": 'El modelo fue entrenado y guardado exitosamente.'})

@app.route("/predict")
def predict():

    datos = request.json
    new_user = datos['user']
    modelo = datos['model']
    version = modelo['version']

    ### Obtenemos el modelo de acuerdo a lo contenido en el json
    if len(modelo) == 1: ### Caso para usar el último modelo
        if version == 'latest':
            aux = [file for file in os.listdir('/app/modelos') if file[-6:] == 'joblib']
            if len(aux) > 0:
                modelo_actual = load('/app/modelos/' + aux[-1])
            else:
                return json.dumps({"message":'Se necesita un modelo. Prueba /train_model, y guárdalo con save_model.'})

        elif version == 'latest_local':
            aux = [file for file in os.listdir('/app/modelos_locales') if file[-6:] == 'joblib']
            if len(aux) > 0:
                modelo_actual = load('/app/modelos_locales/' + aux[-1])
            else:
                return json.dumps({"message":'Se necesita un modelo. Prueba /train_model.'})
        else:
            return json.dumps({"message":'Opción no valida. Elegir "latest", "latest_local", o pasar un json con las especificaciones.'})

    else: ### Caso para especificar cual modelo se quiere usar
            
        selected_model_string = ''
        for s in list(modelo.values())[1:]:
            selected_model_string += s + '_'
        selected_model_string = selected_model_string[:-1]

        aux = [file for file in os.listdir(f'/app/{version}') if file[-6:] == 'joblib']
        if len(aux) > 0:
            try:
                modelo_actual = load(f'app/{version}/random_forest_{selected_model_string}.joblib')              
            except FileExistsError:
                return json.dumps({"message":'El modelo no existe, verifica que los datos de la fecha y tiempo sean correctos.'})    
        else:
            return json.dumps({"message":'Se necesita un modelo. No hay modelos guardados.'})

    new_user = np.array([pd.Series(new_user)])
        
    ### Predecimos con el modelo seleccionado
    if modelo_actual.predict(new_user) == 1:
        return json.dumps({"message": 'Tienes riesgo de sufrir un derrame.'})
    else:
        return json.dumps({"message": 'NO tienes riesgo de sufrir un derrame.'})

@app.route("/save_model", methods=["POST", "GET"])
def save_model():
    if request.method == "POST":
        modelo = request.json
        try:
            selected_model_string = ''
            for s in modelo.values():
                selected_model_string += s + '_'
            selected_model_string = selected_model_string[:-1]
            shutil.copy(f'app/modelos_locales/random_forest_{selected_model_string}.joblib', f'app/modelos/random_forest_{selected_model_string}.joblib')
            shutil.copy(f'app/modelos_locales/random_forest_importancia_{selected_model_string}.png', f'app/modelos/random_forest_importancia_{selected_model_string}.png')
            shutil.copy(f'app/modelos_locales/random_forest_resultados_{selected_model_string}.csv', f'app/modelos/random_forest_resultados_{selected_model_string}.csv')
            return json.dumps({"message":'El modelo se guardó corectamente.'})
        except FileNotFoundError:
            return json.dumps({"message":'El modelo no existe.'})
    if request.method == "GET":
        aux_job = [path.name for path in sorted(Path('app/modelos_locales/').iterdir(), key = os.path.getmtime) if path.name[-6:] == 'joblib']
        aux_png = [path.name for path in sorted(Path('app/modelos_locales/').iterdir(), key = os.path.getmtime) if path.name[-3:] == 'png']
        aux_csv = [path.name for path in sorted(Path('app/modelos_locales/').iterdir(), key = os.path.getmtime) if path.name[-3:] == 'csv']
        if len(aux_job) > 0:
            shutil.copy(f'app/modelos_locales/' + aux_job[-1], f'app/modelos/' + aux_job[-1])
            shutil.copy(f'app/modelos_locales/' + aux_png[-1], f'app/modelos/' + aux_png[-1])
            shutil.copy(f'app/modelos_locales/' + aux_csv[-1], f'app/modelos/' + aux_csv[-1])
            return json.dumps({"message":'El modelo se guardo corectamente.'})
        else:
            return json.dumps({"message":'Se necesita un modelo. Prueba /train_model.'})

@app.route("/show_models")
def show_models():
    aux = [file for file in os.listdir('/app/modelos') if file[-6:] == 'joblib']
    if len(aux) == 0:
        return json.dumps({"message":'No hay modelos guardados'})
    else: 
        return json.dumps({format_file(file):file for file in aux})

@app.route("/show_local_models")
def show_local_models():
    aux = [file for file in os.listdir('/app/modelos_locales') if file[-6:] == 'joblib']
    if len(aux) == 0:
        return json.dumps({"message":'No hay modelos locales guardados'})
    else: 
        return json.dumps({format_file(file):file for file in aux})

@app.route("/show_results")
def show_results():
    aux = [file for file in os.listdir('/app/modelos') if file[-3:] == 'csv']
    if len(aux) == 0:
        return json.dumps({"message":'No hay modelos guardados'})
    else: 
        ### Recuperamos el nombre de los archivos
        files_dict = {format_file(file):file for file in aux}
        files_df = pd.DataFrame(pd.Series(files_dict)).transpose()
        files_df.index = ['file']

        ### Por cada archivo, recuperamos los resultados
        all_results = pd.concat([pd.read_csv('/app/modelos/' + file, index_col = 0) for file in files_dict.values()], axis = 1)
        all_results.columns = files_df.columns
        all_results = pd.concat([files_df, all_results], 0)

        return render_template('simple.html',  tables=[all_results.to_html(classes='data')], titles = all_results.columns.values)

@app.route("/show_local_results")
def show_local_results():
    aux = [file for file in os.listdir('/app/modelos_locales') if file[-3:] == 'csv']
    if len(aux) == 0:
        return json.dumps({"message":'No hay modelos guardados'})
    else: 
        ### Recuperamos el nombre de los archivos
        files_dict = {format_file(file):file for file in aux}
        files_df = pd.DataFrame(pd.Series(files_dict)).transpose()
        files_df.index = ['file']

        ### Por cada archivo, recuperamos los resultados
        all_results = pd.concat([pd.read_csv('/app/modelos_locales/' + file, index_col = 0) for file in files_dict.values()], axis = 1)
        all_results.columns = files_df.columns
        all_results = pd.concat([files_df, all_results], 0)

        return render_template('simple.html',  tables=[all_results.to_html(classes='data')], titles = all_results.columns.values)

@app.route("/tabla_usuarios")
def render_table():
    cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("select * from users")
    results = cur.fetchall()
    cur.close()
    all_data = pd.DataFrame(results, columns = ['id', 'gender', 'age', 'hypertension', 'heart_disease', \
            'ever_married', 'Residence_type', 'avg_glucose_level', 'bmi', 'smoking_status', 'stroke'])

    return render_template('simple.html',  tables=[all_data.to_html(classes='data')], titles=all_data.columns.values)

@app.route('/importance')
def importance():

    aux = [path.name for path in sorted(Path('app/modelos/').iterdir(), key = os.path.getmtime) if path.name[-3:] == 'png']
    if len(aux) == 0:
            return json.dumps({"message":'No hay modelos guardados'})
    else:

        fig, ax = plt.subplots()
        img = mpimg.imread('/app/modelos/' + aux[-1])
        ax.imshow(img)
        ax.set_axis_off()

        output = io.BytesIO()
        FigureCanvas(fig).print_png(output)
        return Response(output.getvalue(), mimetype='image/png')

@app.route('/local_importance')
def local_importance():

    aux = [path.name for path in sorted(Path('app/modelos_locales/').iterdir(), key = os.path.getmtime) if path.name[-3:] == 'png']
    if len(aux) == 0:
            return json.dumps({"message":'No hay modelos guardados'})
    else:

        fig, ax = plt.subplots()
        img = mpimg.imread('/app/modelos_locales/' + aux[-1])
        ax.imshow(img)
        ax.set_axis_off()

        output = io.BytesIO()
        FigureCanvas(fig).print_png(output)
        return Response(output.getvalue(), mimetype='image/png')        

### Sirvió para las pruebas de plot
# def create_figure():
#     fig = Figure()
#     axis = fig.add_subplot(1, 1, 1)
#     xs = range(100)
#     ys = [random.randint(1, 50) for x in xs]
#     axis.plot(xs, ys)
#     return fig

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=8080)

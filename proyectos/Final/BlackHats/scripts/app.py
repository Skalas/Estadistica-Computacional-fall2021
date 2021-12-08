#librerias
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import pickle
import flask


# Initialise the Flask app
app = flask.Flask(__name__, template_folder='templates')

# Set up the main route
@app.route('/', methods=['GET', 'POST'])
def main():
    if flask.request.method == 'GET':
        # Just render the initial form, to get input
        return(flask.render_template('main.html'))
    
    if flask.request.method == 'POST':


        df = pd.read_csv('composicion_invex_sem.txt', sep=" ", header=None)
        df.columns = ['clasificacion','fecha','tipo_valor','emisora','serie','calificacion','importe_mercado','porcentaje']

    #limpieza
    #calificaciones invalidas
        df = df[df.calificacion.str.len()<=8] 
    #calificaciones con 1 observacion
        v = df['calificacion'].value_counts() <10
        df.loc[df['calificacion'].isin(v.index[v]), 'calif_b'] = 'others'
    #series con 1 observacion
        v = df['serie'].value_counts() ==1
        df.loc[df['serie'].isin(v.index[v]), 'level'] = 'others'
        df['serie_b'] = np.where(df['level']=='others', 'others', df['serie'])
    #importe a numero
        df['importe_mercado'] = df['importe_mercado'].str.replace(',','').astype(float)
    #porcentaje a numero
        df['porcentaje'] = df['porcentaje'].str[:-1].astype(float)

    #preparacion para modelo
     
        mod = df[(df.calif_b!='others')][['serie_b','importe_mercado','porcentaje','calificacion']]
     #variables categoricas
        mod['calificacion'] = mod['calificacion'].astype('category').cat.codes
        mod['serie_b'] = mod['serie_b'].astype('category').cat.codes
        #variable dependiente e independientes
        X = mod[['serie_b','importe_mercado','porcentaje']]
        Y= np.array(mod['calificacion'])
 

        A = flask.request.form['serie']
        B = flask.request.form['importe']
        C = flask.request.form['porcentaje']
        D = flask.request.form['reentrenar']
        E = flask.request.form['calificacion']

        # Make DataFrame for model
        input_variables = pd.DataFrame([[A, B,  C]],
                                       columns=['serie_b', 'importe_mercado', 'porcentaje'],
                                       dtype=float,
                                       index=[0])

        if D =='no':
            
            # Use pickle to load in the pre-trained model
            with open(f'model_clf', 'rb') as f:
                model = pickle.load(f)

            # Get the model's prediction
            prediction = model.predict(input_variables)[0]
    
            # Render the form again, but add in the prediction and remind user
            # of the values they input before
            return flask.render_template('main.html',
                                     original_input={'serie':A,
                                                     'importe':B,
                                                     'porcentaje':C},
                                     result=prediction,
                                     result2= 'NA'
                                     )

        else:        # Get the model's prediction
            Y=np.append(Y,E)
            X=X.append(input_variables)


            x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=44)

            #modelo ajustado con randomizedsearchCV
            clf = RandomForestClassifier(n_estimators= 944,
             min_samples_split= 2,
             min_samples_leaf= 1,
             max_depth= 100,
             criterion= 'entropy',
             bootstrap= True)
            clf.fit(x_train,y_train)

        #pickle
            pickle.dump(clf, open("model_clf", "wb"))
            # Use pickle to load in the pre-trained model
            with open(f'model_clf', 'rb') as f:
                model = pickle.load(f)
            # Get the model's prediction
            prediction = model.predict(input_variables)[0]

    
        # Render the form again, but add in the prediction and remind user
        # of the values they input before
            return flask.render_template('main.html',
                                         original_input={'serie':A,
                                                         'importe':B,
                                                         'porcentaje':C,
                                                         'calificacion':E},
                                         result=prediction,
                                         result2='EXITOSO'
                                         )

if __name__ == '__main__':
    app.run()
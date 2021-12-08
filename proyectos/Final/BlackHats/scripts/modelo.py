#Modelo de Clasificación para la Calificación de los Instrumentos
#Financieros de INVEX
#Variable dependiente: calificación 
#Variables independientes: serie, importe mercado y porcentaje de portafolio

#librerias
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import pickle



#lectura
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
#dividimos en train y test
x_train, x_test, y_train, y_test = train_test_split(X, Y, test_size=0.2, random_state=44)

#modelo ajustado con randomizedsearchCV
clf = RandomForestClassifier(n_estimators= 944,
 min_samples_split= 2,
 min_samples_leaf= 1,
 max_depth= 100,
 criterion= 'entropy',
 bootstrap= True)
clf.fit(x_train,y_train)

#predicciones
probs = clf.predict_proba(x_test)
y_pred = clf.predict(x_test)

#pickle
pickle.dump(clf, open("model_clf", "wb"))
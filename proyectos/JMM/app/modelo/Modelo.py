#!/usr/bin/env python
# coding: utf-8

# Importar datos
import psycopg2
import psycopg2.extras
import pandas as pd
#import os

database_uri = 'postgresql://postgres:postgres@0.0.0.0:5432/postgres'

conn = psycopg2.connect(database_uri)

cur = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
cur.execute("select * from produccion")
results = cur.fetchall()
cur.close()

dta = pd.DataFrame(results)

# In[111]:

import numpy as np

col_names = ['anio','num_estado', 'estado','id_ciclo', 'nom_ciclo','id_mod',
             'modalidad','id_u_medida','nom_u_medida','id_cultivo','nom_cultivo',
            'sembrada','cosechada','siniestrada','volumen_prod', 
            'rendimiento','precio']

dta.columns = col_names

dta = dta.astype({'anio':'int32',
    'sembrada':'float32',
    'cosechada':'float32',
    'siniestrada':'float32',
    'volumen_prod':'float32',
    'rendimiento':'float32',
    'precio':'float32'})


dta = dta.groupby(['anio','estado', 'modalidad']).\
    agg({'sembrada': 'sum', 'cosechada': 'sum', 'siniestrada' : 'sum',
         'rendimiento':'mean', 'volumen_prod':'sum'}).\
        reset_index()

# Razones por las que se quita cada variable:
# 
# - volumen_prod:  es Y
# - precio: depende de volumen_prod
# - nom_u_medida: todas son toneladas
# - nom_cultivo: todas son manzana
# - nom_ciclo: todas son Perennes
# - num_estado: redundante con 'estado'
# - todas las que comienzan con id

# In[112]:

X = dta.drop(columns = ['volumen_prod'])

Y = dta['volumen_prod']

# Homogeneizar valores que contengan 'Ciudad' de con 'cdmx' 

# In[113]:

X.loc[X['estado'].str.contains('Ciudad de'), 'estado'] = 'cdmx'

# In[116]:
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.compose import make_column_selector
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline

from sklearn.model_selection import train_test_split

# In[119]: Selectors y processors

cat_selector = make_column_selector(dtype_include=object)
num_selector = make_column_selector(dtype_include=np.number)

cat_processor = OneHotEncoder()
num_processor = SimpleImputer(strategy = "constant", fill_value = 0)


rf_preprocessor = make_column_transformer(
    (cat_processor,cat_selector),(num_processor,num_selector)
)


rf_pipeline = make_pipeline(rf_preprocessor, RandomForestRegressor(random_state=42))

X_train, X_test, y_train, y_test = train_test_split(X, Y, shuffle = False)

rf_pipeline.fit(X_train,y_train)

rf_pipeline.score(X_test, y_test)

rf_pipeline.predict(X_test)

# Almacena modelo

import pickle as pkl

with open('modelo_fit.pkl', 'wb') as f: pkl.dump(rf_pipeline, f)


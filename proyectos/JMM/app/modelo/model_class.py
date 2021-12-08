#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  6 18:20:50 2021

@author: mario
"""

#Modelo pero por modulos

#import psycopg2
#import psycopg2.extras
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.compose import make_column_selector
from sklearn.compose import make_column_transformer
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import train_test_split
import pickle

class InitialModel:
    
    def __init__(self):
        self.dummy = "dummy"


    def _procesa_data(self):
        
        col_names = ['anio','num_estado', 'estado','id_ciclo', 'nom_ciclo','id_mod',
                     'modalidad','id_u_medida','nom_u_medida','id_cultivo','nom_cultivo',
                    'sembrada','cosechada','siniestrada','volumen_prod', 
                    'rendimiento','precio']

        self.dta.columns = col_names

        self.dta = self.dta.astype({'anio':'int32',
            'sembrada':'float32',
            'cosechada':'float32',
            'siniestrada':'float32',
            'volumen_prod':'float32',
            'rendimiento':'float32',
            'precio':'float32'})

        X = self.dta.drop(columns = ['volumen_prod','precio', 'nom_u_medida','nom_cultivo', 'nom_ciclo', 'num_estado'])
        X = X.loc[:,~X.columns.str.startswith('id_')]
        X.loc[X['estado'].str.contains('Ciudad de'), 'estado'] = 'cdmx'
        
        self.X = X
        self.Y = self.dta['volumen_prod']
        
    def ajusta_modelo(self,df):
        
        self.dta = pd.DataFrame(df)
        self._procesa_data()
        
        cat_selector = make_column_selector(dtype_include=object)
        num_selector = make_column_selector(dtype_include=np.number)

        cat_processor = OneHotEncoder()
        num_processor = SimpleImputer(strategy = "constant", fill_value = 0)


        rf_preprocessor = make_column_transformer(
            (cat_processor,cat_selector),(num_processor,num_selector)
        )


        self.rf_pipeline = make_pipeline(rf_preprocessor, RandomForestRegressor(random_state=42))

        X_train, X_test, y_train, y_test = train_test_split(self.X, self.Y, shuffle = False)

        self.rf_pipeline.fit(X_train,y_train)
        
        mod_pkl = pickle.dumps(self.rf_pipeline)
        
        return mod_pkl
        
class Predictions:
    
    def __init__(self):
        self.dummy = "dummy"
        
        
    def _procesa_data_pred(self):
        
        col_names = ['anio','num_estado', 'estado','id_ciclo', 'nom_ciclo','id_mod',
                     'modalidad','id_u_medida','nom_u_medida','id_cultivo','nom_cultivo',
                    'sembrada','cosechada','siniestrada','volumen_prod', 
                    'rendimiento','precio']

        self.dta.columns = col_names

        self.dta = self.dta.astype({'anio':'int32',
            'sembrada':'float32',
            'cosechada':'float32',
            'siniestrada':'float32',
            'volumen_prod':'float32',
            'rendimiento':'float32',
            'precio':'float32'})
        
        self.dta = self.dta.groupby(['anio','estado', 'modalidad']).\
            agg({'sembrada': 'sum', 'cosechada': 'sum', 'siniestrada' : 'sum',
                 'rendimiento':'mean', 'volumen_prod':'sum'}).\
                reset_index()

        X = self.dta.drop(columns = ['volumen_prod'])
        X.loc[X['estado'].str.contains('Ciudad de'), 'estado'] = 'cdmx'
        
        self.X = X
      
    
    def predict(self, mod_pkl, df):
        
        self.dta = pd.DataFrame(df)
        self._procesa_data_pred()
        model = pickle.loads(mod_pkl[-1])
        
        preds = model.predict(self.X)
        
        return preds
    
    
    
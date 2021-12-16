from sklearn.model_selection import train_test_split
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV, ParameterGrid
from sklearn.model_selection import cross_validate
from sklearn.linear_model import LogisticRegression, Perceptron, SGDClassifier
from sklearn.metrics import log_loss
from sklearn.feature_selection import mutual_info_classif
from sklearn.feature_selection import SelectKBest
from sklearn.pipeline import Pipeline
from sklearn.neighbors import KNeighborsClassifier
from xgboost import XGBClassifier
import xgboost as xgb
from sklearn.metrics import accuracy_score
from time import time
import pandas as pd
import pickle


class MLModeling():
    def __init__(self, dataframe):
        self.dataframe = dataframe
    
    def modeling(self):
        X = self.dataframe.drop(['result'], axis=1)
        y = self.dataframe['result']
        #X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=12345)
        #modelos={}
      
      # xgboost
        model_xgb = xgb.XGBClassifier(
                                        n_estimators=10,
                                        max_depth=7,
                                        learning_rate=0.4,
                                        colsample_bytree=0.6,
                                        missing=-999,
                                        random_state=66
                                     )
        model_xgb.fit(X, y)
        #yhat_xgb = model_xgb.predict(X_test)
        #acc_xgb = accuracy_score(y_test, yhat_xgb)
        #modelos['xgb']=acc_xgb
        #with open('entrenamiento_xgb.pkl', 'wb') as file:
        #    pickle.dumps(model_xgb)
        pickle.dump(model_xgb, open('data/entrenamiento_xgb.pkl', 'wb'))
 


        
      # logistic regression
        model_lr = LogisticRegression(
                                        penalty = 'l2',
                                        C= 1,
                                        solver='lbfgs'
                                      )
        model_lr.fit(X, y)
#         yhat_lr = model_lr.predict(X_test)
#         acc_lr = accuracy_score(y_test, yhat_lr)
#         modelos['lr']=acc_lr
        pickle.dump(model_lr, open('data/entrenamiento_lr.pkl', 'wb'))

      # KNN
        model_knn=KNeighborsClassifier(
                                        n_neighbors=10,
                                        weights='uniform',
                                        algorithm='auto'
                                      )
        model_knn.fit(X, y)
#         with open('entrenamiento_knn.pkl', 'wb') as file:
#             pickle.dump(model_knn.predict_proba(X_train), file)
        pickle.dump(model_knn, open('data/entrenamiento_knn.pkl', 'wb'))
        
#         with open('entrenamiento_knn_parametros.pkl', 'wb') as file:
#             pickle.dump(model_knn.get_params(), file)
            
#         print("############## Precisión de los modelos", modelos)
#         with open('precision_modelos.pkl', 'wb') as file:
#             pickle.dump(modelos, file)
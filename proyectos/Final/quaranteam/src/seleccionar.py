from sklearn.metrics import accuracy_score
import pickle

#Selecciona el mejor modelo de acuerdo al accuracy
class selecciona():
#     def __init__(self, diccionario):
#         self.diccionario = diccionario
        
    def __init__(self, dataframe):
        self.dataframe = dataframe
  
    def seleccion(self):
        X = self.dataframe.drop(['result'], axis=1)
        y = self.dataframe['result']
        
        acc_xgb = accuracy_score(y, pickle.load(open('data/entrenamiento_xgb.pkl', 'rb')).predict(X))
        acc_lr = accuracy_score(y, pickle.load(open('data/entrenamiento_lr.pkl', 'rb')).predict(X))
        acc_knn = accuracy_score(y, pickle.load(open('data/entrenamiento_knn.pkl', 'rb')).predict(X))
        
        
        acc_diccionario = {"XGB": acc_xgb, "LR": acc_lr, "KNN": acc_knn}
        print("####### Las precisiones de los modelos son: ", acc_diccionario)
                
        mejor_modelo=max(acc_diccionario, key=acc_diccionario.get)
        acc_mejor_modelo=max(acc_diccionario.values())
                
        print("####### Mejor modelo: ", mejor_modelo)
        print("####### El accuracy del mejor modelo es: ", acc_mejor_modelo)
      
        return mejor_modelo,acc_mejor_modelo


    


#yhat_xgb = model_xgb.predict(X_test)
#acc_xgb = accuracy_score(y_test, yhat_xgb)

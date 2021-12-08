from sklearn.metrics import accuracy_score
import pandas as pd
from sklearn.model_selection import train_test_split
import xgboost as xgb
from sklearn.linear_model import LogisticRegression 
from sklearn.neighbors import KNeighborsClassifier
import pickle

class MLSelection():
    def __init__(self, dataframe):
        self.dataframe = dataframe
  
    def selection(self):
      
      X = self.dataframe.drop(['result'], axis=1)
      y = self.dataframe['result']
      X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25)

      # Load from file
      pkl_filename = "pickle_model.pkl"
      with open(pkl_filename, 'rb') as file:
        pickle_model = pickle.load(file)
    
      # Calculate the accuracy score and predict target values
      score = pickle_model.score(X_test, y_test)
      print("Test score: {0:.2f} %".format(100 * score))
      Ypredict = pickle_model.predict(X_test)
      
      return score,Ypredict

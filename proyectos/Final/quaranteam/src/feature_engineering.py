import pandas as pd
from sklearn.preprocessing import LabelEncoder 

class FeatureEngineering():
    def __init__(self, dataframe):
        self.dataframe = dataframe
  
    def feature_engineering(self):
        self.dataframe = self.dataframe.dropna()
        columns_to_drop = ["JOB_PROGRESS","BBL","BLOCK","LOT","HOUSE_NUMBER","STREET_NAME","X_COORD","Y_COORD","BOROUGH","LOCATION","APPROVED_DATE"]
        self.dataframe = self.dataframe.drop(columns_to_drop,axis=1)
        self.dataframe.columns = ["Ins_type","job_ticket","job_id","boro_code","zc","lat","long","ins_date","result"]
        self.dataframe = self.dataframe.drop(self.dataframe[self.dataframe.lat < 30].index)
        self.dataframe.drop_duplicates()
        def conditions(s):
            if (s['result'] == "Bait applied") or (s['result'] == "Monitoring visit"):
                return 1
            else:
                return 0
        self.dataframe['result'] = self.dataframe.apply(conditions, axis=1)
        Insp = pd.get_dummies(self.dataframe['Ins_type'])
        Insp=Insp.join(self.dataframe.job_id)
        train = pd.merge(self.dataframe.drop(['ins_date', 'Ins_type'], axis = 1),Insp, on="job_id")
        le = LabelEncoder()
        train['boro_code'] = le.fit_transform(train['boro_code'])
        train['result'] = le.fit_transform(train['result'])
        rain['job_id'] = le.fit_transform(train['job_id'].astype(str))
      
        return train

import pandas as pd
import pickle
import psycopg2
import psycopg2.extras
import json
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.cluster import KMeans
import warnings


def modeling(num_clusters,calibration = True):
    """
    Calibracion de modelo para realizar clustering
    num_clusters = numero de grupos a formar
    calibration = True para calibrar el modelo completamento, False para hacer prediccion
    """    
    
    warnings.filterwarnings("ignore")
    
    if calibration == True:

        #---------
        #Read data
        #---------
        
        #pokemon = pd.read_csv('data/pokemon.csv')

        connection = psycopg2.connect(user="postgres",
                                      password="pokemon",
                                      host="db",
                                      port="5432")
        cursor = connection.cursor()

        cur = connection.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("SELECT * FROM pokemon_;")
        results = cur.fetchall()
        cur.close()
        results = json.dumps([x._asdict() for x in results], default=str)
        pokemon = pd.read_json(results)

        #-------------
        #Data cleaning
        #-------------
        
        median_height = pokemon.height_m.median()
        median_weight = pokemon.weight_kg.median()

#        pickle.dump(median_height,open('src/median_height.pkl','wb'))
#        pickle.dump(median_weight,open('src/median_weight.pkl','wb'))

        pickle.dump(median_height,open('median_height.pkl','wb'))
        pickle.dump(median_weight,open('median_weight.pkl','wb'))
        
        porcentaje_macho = 110
        tipo_2_input = 'Ninguna'
        
        #---------------
        #Data inputation
        #---------------
        
        pokemon['height_m'] = pokemon.height_m.fillna(median_height)
        pokemon['weight_kg'] = pokemon.weight_kg.fillna(median_weight)
        pokemon['percentage_male'] = pokemon.percentage_male.fillna(porcentaje_macho)
        pokemon['type2'] = pokemon.type2.fillna(tipo_2_input)
        
        #Regresar cuando se conecte la base via bash
        pokemon['abilities'] = pokemon['abilities'].apply(lambda x: x.replace("'", ''))

        # pokemon['abilities'] = pokemon['abilities'].apply(lambda x: x.strip.split(', '))
        
        # abilities_f = []
        # for i in range(pokemon.shape[0]):
        #     abilities = ''
        #     for j in pokemon['abilities'][i]:
        #         abilities += (' ' + j.split("*")[1])
           
        #     abilities_f.append(abilities.strip())
            
        # pokemon['abilities'] = abilities_f
        
#        cv_ab = CountVectorizer(ngram_range=(1,1), min_df=10, max_df=1.0, max_features=100)
        cv_ab = CountVectorizer(ngram_range=(1,1), min_df=1, max_df=1.0, max_features=100)

        cv_ab.fit(pokemon['abilities'])
        ab_w = pd.DataFrame(data=cv_ab.transform(pokemon['abilities']).todense(),
                              columns=[f"ability_{x}" for x in cv_ab.get_feature_names()])
        
        pokemon = pokemon.drop(columns = ['abilities']).join(ab_w)
        
#        capture_index = pokemon[pokemon['capture_rate'] == '30 (Meteorite)255 (Core)'].index[0]
#        pokemon['capture_rate'][capture_index] = 30
        
        pokemon['capture_rate'] = pokemon['capture_rate'].astype(int)
        
        pokemon.drop(columns = ['japanese_name'], inplace = True)
        
        pokemon_2 = pokemon.copy()[['name','type1']]
        pokemon_3 = pokemon.copy()[['name','type2']]
        pokemon_3.rename(columns = {'type2': 'type1'}, inplace = True)
        type_f = pd.concat((pokemon_2, pokemon_3), axis = 0,ignore_index = True)
        
        type_f['dumm'] = 1
        agg_data = type_f.pivot_table(index = 'name', columns=['type1'], aggfunc="sum", fill_value=0)
        agg_data.columns = agg_data.columns.droplevel(0)
        agg_2 = agg_data.reset_index()
        
        pokemon = pokemon.merge(agg_2, how = 'left', on = 'name')
        
        pokemon.drop(columns = [#'Classfication', 
                                #'Type1', 'Type2', 
                                'pokedex_number'], inplace = True)
        pokemon.set_index(pokemon['name'], inplace = True)
        pokemon.drop(columns = ['name'], inplace = True)
        
        #-------------------
        #Dimention reduction
        #-------------------
        
        X = pokemon.drop(columns = ['classfication','type1', 'type2']).copy()
        
        scaler = StandardScaler()
        scaler.fit(X)
        
        Xs = pd.DataFrame(scaler.transform(X),columns=X.columns,index=X.index)
        tsne = TSNE(n_components=2, perplexity=0)
        
        #-----
        #T-SNE
        #-----
        
        tsne = TSNE(random_state=777, perplexity=50,learning_rate=160)
        pokemon_tsne = pd.DataFrame(data=tsne.fit_transform(Xs), columns=["d1", "d2"],index=Xs.index) 
        
        #----------
        #Clustering
        #----------
        
        df_modelado=Xs
        df_original=pokemon
        df_escalado=pokemon_tsne
        
        cluster_kmeans = KMeans(n_clusters=num_clusters, #n_jobs=-1, 
                                random_state=210327,max_iter=1000)
        modelo_cluster_kmeans = cluster_kmeans.fit(df_modelado)
        fit_cluster_kmeans = modelo_cluster_kmeans.predict(df_modelado)
#        pickle.dump(modelo_cluster_kmeans,open('modelos/modelo_cluster_kmeans.pkl','wb'))
        pickle.dump(modelo_cluster_kmeans,open('modelo_cluster_kmeans.pkl','wb'))
        df_original["cl_kmeans"] = df_escalado["cl_kmeans"] = [str(x) for x in fit_cluster_kmeans]

        df_modelado=pokemon_tsne
        df_original=pokemon
        df_escalado=pokemon_tsne
        
        cluster_kmeans_t = KMeans(n_clusters=num_clusters, #n_jobs=-1, 
                                  random_state=210327,max_iter=1000)
        modelo_cluster_kmeans_t = cluster_kmeans_t.fit(df_modelado)
        fit_cluster_kmeans_t = modelo_cluster_kmeans_t.predict(df_modelado)
#        pickle.dump(modelo_cluster_kmeans_t,open('modelos/modelo_cluster_kmeans_t.pkl','wb'))
        pickle.dump(modelo_cluster_kmeans_t,open('modelo_cluster_kmeans_t.pkl','wb'))
        df_original["cl_kmeans_t"] = df_escalado["cl_kmeans_t"] = [str(x) for x in fit_cluster_kmeans_t]
        df_original["cl_kmeans_t"] = df_escalado["cl_kmeans_t"] = [str(x) for x in fit_cluster_kmeans_t]

    else:
 
        #---------
        #Read data
        #---------
        
        #pokemon = pd.read_csv('data/pokemon.csv')

        connection = psycopg2.connect(user="postgres",
                                      password="pokemon",
                                      host="db",
                                      port="5432")
        cursor = connection.cursor()

        cur = connection.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        cur.execute("SELECT * FROM pokemon_;")
        results = cur.fetchall()
        cur.close()
        results = json.dumps([x._asdict() for x in results], default=str)
        pokemon = pd.read_json(results)
            
        #-------------
        #Data cleaning
        #-------------
        
#        median_height = pd.read_pickle(r'src/median_height.pkl')
#        median_weight = pd.read_pickle(r'src/median_weight.pkl')

        median_height = pd.read_pickle(r'median_height.pkl')
        median_weight = pd.read_pickle(r'median_weight.pkl')


        porcentaje_macho = 110
        tipo_2_input = 'Ninguna'
        
        #---------------
        #Data inputation
        #---------------
        
        pokemon['height_m'] = pokemon.height_m.fillna(median_height)
        pokemon['weight_kg'] = pokemon.weight_kg.fillna(median_weight)
        pokemon['percentage_male'] = pokemon.percentage_male.fillna(porcentaje_macho)
        pokemon['type2'] = pokemon.type2.fillna(tipo_2_input)
        
        pokemon['abilities'] = pokemon['abilities'].apply(lambda x: x.replace("'", ''))
        # pokemon['abilities'] = pokemon['abilities'].apply(lambda x: x.split(', '))
        
        # abilities_f = []
        # for i in range(pokemon.shape[0]):
        
        #     abilities = ''
        #     for j in pokemon['abilities'][i]:
        #         abilities += (' ' + j.split("*")[1])
            
        #     abilities_f.append(abilities.strip())
            
        # pokemon['abilities'] = abilities_f
        
#        cv_ab = CountVectorizer(ngram_range=(1,1), min_df=10, max_df=1.0, max_features=100)
        cv_ab = CountVectorizer(ngram_range=(1,1), min_df=1, max_df=1.0, max_features=100)
        cv_ab.fit(pokemon['abilities'])
        ab_w = pd.DataFrame(data=cv_ab.transform(pokemon['abilities']).todense(),
                              columns=[f"ability_{x}" for x in cv_ab.get_feature_names()])
        
        pokemon = pokemon.drop(columns = ['abilities']).join(ab_w)
        
#        Corregir cuando se ponga en productivo
#        capture_index = pokemon[pokemon['capture_rate'] == '30 (Meteorite)255 (Core)'].index[0]
#        pokemon['capture_rate'][capture_index] = 30
        
        pokemon['capture_rate'] = pokemon['capture_rate'].astype(int)
        
        pokemon.drop(columns = ['japanese_name'], inplace = True)
        
        pokemon_2 = pokemon.copy()[['name','type1']]
        pokemon_3 = pokemon.copy()[['name','type2']]
        pokemon_3.rename(columns = {'type2': 'type1'}, inplace = True)
        type_f = pd.concat((pokemon_2, pokemon_3), axis = 0,ignore_index = True)
        
        type_f['dumm'] = 1
        agg_data = type_f.pivot_table(index = 'name', columns=['type1'], aggfunc="sum", fill_value=0)
        agg_data.columns = agg_data.columns.droplevel(0)
        agg_2 = agg_data.reset_index()
        
        pokemon = pokemon.merge(agg_2, how = 'left', on = 'name')
        
        pokemon.drop(columns = [#'Classfication', 
                                #'Type1', 'Type2', 
                                'pokedex_number'], inplace = True)
        pokemon.set_index(pokemon['name'], inplace = True)
        pokemon.drop(columns = ['name'], inplace = True)
        
        #-------------------
        #Dimention reduction
        #-------------------
        
        X = pokemon.drop(columns = ['classfication','type1', 'type2']).copy()
        
        scaler = StandardScaler()
        scaler.fit(X)
        
        Xs = pd.DataFrame(scaler.transform(X),columns=X.columns,index=X.index)
        tsne = TSNE(n_components=2, perplexity=0)
        
        #-----
        #T-SNE
        #-----
        
        tsne = TSNE(random_state=777, perplexity=50,learning_rate=160)
        pokemon_tsne = pd.DataFrame(data=tsne.fit_transform(Xs), columns=["d1", "d2"],index=Xs.index) 
        
        #----------
        #Clustering
        #----------
        
        df_modelado=Xs
        df_original=pokemon
        df_escalado=pokemon_tsne
        
#        modelo_cluster_kmeans = pd.read_pickle(r'modelos/modelo_cluster_kmeans.pkl')
        modelo_cluster_kmeans = pd.read_pickle(r'modelo_cluster_kmeans.pkl')
        fit_cluster_kmeans = modelo_cluster_kmeans.predict(df_modelado)
        df_original["cl_kmeans"] = df_escalado["cl_kmeans"] = [str(x) for x in fit_cluster_kmeans]

        df_modelado=pokemon_tsne
        df_original=pokemon
        df_escalado=pokemon_tsne

#        modelo_cluster_kmeans_t = pd.read_pickle(r'modelos/modelo_cluster_kmeans_t.pkl')
        modelo_cluster_kmeans_t = pd.read_pickle(r'modelo_cluster_kmeans_t.pkl')
        fit_cluster_kmeans_t = modelo_cluster_kmeans_t.predict(df_modelado)
        df_original["cl_kmeans_t"] = df_escalado["cl_kmeans_t"] = [str(x) for x in fit_cluster_kmeans_t]

        return df_original.reset_index()[["name","cl_kmeans_t"]]

def prediction(num_clusters,dataframe,length):
    """
    Calibracion de modelo para realizar clustering
    num_clusters = numero de grupos a formar
    calibration = True para calibrar el modelo completamento, False para hacer prediccion
    """    
    
    #---------
    #Read data
    #---------
    connection = psycopg2.connect(user="postgres",
                                password="pokemon",
                                host="db",
                                port="5432")
    cursor = connection.cursor()

    cur = connection.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
    cur.execute("SELECT * FROM pokemon_;")
    results = cur.fetchall()
    cur.close()
    results = json.dumps([x._asdict() for x in results], default=str)
    pokemon1 = pd.read_json(results)
    pokemon1 = pd.DataFrame(pokemon1)
    pokemon = pd.concat([pokemon1,dataframe],axis=0).reset_index(drop=True)
            
    #-------------
    #Data cleaning
    #-------------
        
    median_height = pd.read_pickle(r'median_height.pkl')
    median_weight = pd.read_pickle(r'median_weight.pkl')

    porcentaje_macho = 110
    tipo_2_input = 'Ninguna'
        
    #---------------
    #Data inputation
    #---------------
        
    pokemon['height_m'] = pokemon.height_m.fillna(median_height)
    pokemon['weight_kg'] = pokemon.weight_kg.fillna(median_weight)
    pokemon['percentage_male'] = pokemon.percentage_male.fillna(porcentaje_macho)
    pokemon['type2'] = pokemon.type2.fillna(tipo_2_input)
        
    pokemon['abilities'] = pokemon['abilities'].apply(lambda x: x.replace("'", ''))
        
    cv_ab = CountVectorizer(ngram_range=(1,1), min_df=1, max_df=1.0, max_features=100)
    cv_ab.fit(pokemon['abilities'])
    ab_w = pd.DataFrame(data=cv_ab.transform(pokemon['abilities']).todense(),
                        columns=[f"ability_{x}" for x in cv_ab.get_feature_names()])
        
    pokemon = pokemon.drop(columns = ['abilities']).join(ab_w)
        
    pokemon['capture_rate'] = pokemon['capture_rate'].astype(int)
        
    pokemon.drop(columns = ['japanese_name'], inplace = True)
        
    pokemon_2 = pokemon.copy()[['name','type1']]
    pokemon_3 = pokemon.copy()[['name','type2']]
    pokemon_3.rename(columns = {'type2': 'type1'}, inplace = True)
    type_f = pd.concat((pokemon_2, pokemon_3), axis = 0,ignore_index = True)
        
    type_f['dumm'] = 1
    agg_data = type_f.pivot_table(index = 'name', columns=['type1'], aggfunc="sum", fill_value=0)
    agg_data.columns = agg_data.columns.droplevel(0)
    agg_2 = agg_data.reset_index()
        
    pokemon = pokemon.merge(agg_2, how = 'left', on = 'name')
        
    pokemon.drop(columns = [#'Classfication', 
                        #'Type1', 'Type2', 
                        'pokedex_number'], inplace = True)
    pokemon.set_index(pokemon['name'], inplace = True)
    pokemon.drop(columns = ['name'], inplace = True)
        
    #-------------------
    #Dimention reduction
    #-------------------
        
    X = pokemon.drop(columns = ['classfication','type1', 'type2']).copy()
        
    scaler = StandardScaler()
    scaler.fit(X)
        
    Xs = pd.DataFrame(scaler.transform(X),columns=X.columns,index=X.index)
    tsne = TSNE(n_components=2, perplexity=0)
        
    #-----
    #T-SNE
    #-----
        
    tsne = TSNE(random_state=777, perplexity=50,learning_rate=160)
    pokemon_tsne = pd.DataFrame(data=tsne.fit_transform(Xs), columns=["d1", "d2"],index=Xs.index) 
        
    #----------
    #Clustering
    #----------
        
    df_modelado=Xs
    df_original=pokemon
    df_escalado=pokemon_tsne
        
    modelo_cluster_kmeans = pd.read_pickle(r'modelo_cluster_kmeans.pkl')
    fit_cluster_kmeans = modelo_cluster_kmeans.predict(df_modelado)
    df_original["cl_kmeans"] = df_escalado["cl_kmeans"] = [str(x) for x in fit_cluster_kmeans]

    df_modelado=pokemon_tsne
    df_original=pokemon
    df_escalado=pokemon_tsne

    modelo_cluster_kmeans_t = pd.read_pickle(r'modelo_cluster_kmeans_t.pkl')
    fit_cluster_kmeans_t = modelo_cluster_kmeans_t.predict(df_modelado)
    df_original["cl_kmeans_t"] = df_escalado["cl_kmeans_t"] = [str(x) for x in fit_cluster_kmeans_t]


#    return pokemon.reset_ind  ex().tail(2)
    return df_original.reset_index()[["name","cl_kmeans_t"]].tail(length)
#    return df_original.reset_index()[["name","d1","d2","cl_kmeans_t"]]
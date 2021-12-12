# Agregar base de datos de forma inicial
docker exec web_miguel_adrian curl -X POST -H "Content-Type: application/json" -d @app/datos_json.txt 0.0.0.0:8080/users

# Ejemplo de POST para un solo user: 
curl -X POST -H "Content-Type: application/json"\
     -d '{"gender": 1, "age": 67, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}'\
     0.0.0.0:8080/user

# Ejemplo de DELETE para user: 
curl -X DELETE '0.0.0.0:8080/user?id=2'

# Ejemplo de GET para user: 
curl '0.0.0.0:8080/user?id=3'

# Ejemplo de PATCH para user: 
curl -X PATCH -H "Content-Type: application/json"\
     -d '{"gender": 0, "age": 6700, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}'\
     '0.0.0.0:8080/user?id=4'

# Ejemplo de GET para users (regresa toda la base de datos): 
curl '0.0.0.0:8080/users'

# Ejemplo de POST para múltiples users: 
curl -X POST -H "Content-Type: application/json"\
     -d '[{"gender": 1, "age": 67, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}, 
          {"gender": 0, "age": 64, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "228.69", "bmi": "36.6", "smoking_status": 2, "stroke": 1}]' \
          0.0.0.0:8080/users

# Ejemplo de DELETE para múltiples users: 
curl -X DELETE -H "Content-Type: application/json"\
     -d '{"id": [1,2,3,4,5,6,7,8]}'\
     '0.0.0.0:8080/users'

# Ejemplo de Predicción (cuidado de checar la fecha!)
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":
			{
					"gender": 1, 
					"age": 2, 
					"hypertension": 0, 
					"heart_disease": 1, 
					"ever_married": 1, 
					"Residence_type": 1, 
					"avg_glucose_level": "1000.69", 
					"bmi": "36.6",
					"smoking_status": 1
			},

	"model":
			{
					"version": "modelos_locales",
					"year": "2021",
					"month": "12",
					"day": "05",
					"hour": "01",
					"minute": "23",
					"second": "10"
			}
}'\
     '0.0.0.0:8080/predict'

# Ejemplo de Predicción con el modelo dentro del docker más reciente
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":{"gender": 1, "age": 2, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "1000.69", "bmi": "36.6","smoking_status": 1},
	"model": {"version": "latest_local"} }'\
     '0.0.0.0:8080/predict'     

# Ejemplo de Predicción con el modelo fuera de docker más reciente (Carpeta /app/modelos)
curl -X GET -H "Content-Type: application/json"\
     -d '{ 
	"user":{"gender": 1, "age": 2, "hypertension": 0, "heart_disease": 1, "ever_married": 1, "Residence_type": 1, "avg_glucose_level": "1000.69", "bmi": "36.6","smoking_status": 1},
	"model": {"version": "latest"} }'\
     '0.0.0.0:8080/predict'

# Salvar un modelo específico afuera de docker.

curl -X POST -H "Content-Type: application/json"\
     -d '{"year": "2021","month": "12","day": "05","hour": "01","minute": "23","second": "10"}' \
     '0.0.0.0:8080/save_model'


# Salvar el modelo más reciente a modelos.
curl '0.0.0.0:8080/save_model'

# Ejemplo de entrenar modelo pasándole la grid
curl -X GET -H "Content-Type: application/json"\
     -d '{"n_estimators": [60, 80], "max_features": [2, 4]}'\
     '0.0.0.0:8080/train_model'

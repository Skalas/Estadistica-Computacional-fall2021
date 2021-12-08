# Estadística Computacional
---
## Proyecto Final

### Descripción
Este repositorio contiene un modelo de decenso de gradiente (model/gbr.pkl) que predice el ingreso estimado de una persona. El modelo puede recibir solicituded json mediante un Flask REST API.

### Forma de uso
La aplicación de Flask puede recibir dos tipos de solicitud (POST requests).

1. Predecir de ingresos
Envía un json con las características de las personas cuyos ingresos quieres estimar.

El modelo necesita 10 características (variables independientes) para hacer una predicción.

Por ejemplo, si quieres predecir el ingreso de dos personas, puedes enviar:
```
[
	{
		"internet":1,
		"edad":34,
		"habla_ind":0,
		"horas_tr":11.5,
		"horas_qr":3,
		"educ":3,
		"autos":2,
		"cuartos":4,
		"mujer":1,
		"resid":5
	},
	{
		"internet":1,
		"edad":45,
		"habla_ind":0,
		"horas_tr":90,
		"horas_qr":3,
		"educ":4,
		"autos":2,
		"cuartos":4,
		"mujer":1,
		"resid":5
	}
]
```

2. Ingresa nuevos datos y recalibra el modelo
Puedes ingresar nuevos y solicitar que el modelo se reentrene agregando estos registros a la base original.

Solo verifica que tus datos contengan el ingreso observado y las 10 características (variables) necesarias.
```
[
	{
		"ingreso":45000,
		"internet":1,
		"edad":28,
		"habla_ind":0,
		"horas_tr":0,
		"horas_qr":1,
		"educ":2,
		"autos":2,
		"cuartos":10,
		"mujer":0,
		"resid":3
	},
	{
		"ingreso":70000,
		"internet":1,
		"edad":33,
		"habla_ind":0,
		"horas_tr":60,
		"horas_qr":5,
		"educ":2,
		"autos":2,
		"cuartos":5,
		"mujer":1,
		"resid":2
	},
	{
		"ingreso":40000,
		"internet":1,
		"edad":57,
		"habla_ind":0,
		"horas_tr":20,
		"horas_qr":4,
		"educ":3,
		"autos":2,
		"cuartos":10,
		"mujer":1,
		"resid":3
	}
]
```
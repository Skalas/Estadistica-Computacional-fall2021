## Comprensión de negocio

### Antecedentes

Las ratas noruegas llegaron por primera vez a la ciudad de Nueva York en el siglo XVIII, y a medida que la población de la ciudad crecía, también lo hacía la población de roedores. La ciudad alberga una de las poblaciones de ratas más grandes de los Estados Unidos. En Nueva York, el control de roedores está a cargo de la Oficina de Control de plagas de la Oficina de servicios veterinarios y de control de plagas dentro de la División de Salud Ambiental de la Ciudad de Nueva York Departamento de Salud e Higiene Mental (NYC DOHMH). NYC DOHMH ha realizado actividades de control de roedores por más de 100 años. Es importante mencionar que las actividades de control de roedores están financiadas por soporte local. 

### Determinación del objetivo

El reto del proyecto consta en poder predecir si podemos predecir el resultado de la inspección a partir de la ubicación y características de la propiedad próxima a ser inspeccionada

### Determinación de criterio de éxito

El principal reto del proyecto es obtener un *accuracy* superior al 70%.

### Plan del proyecto


Nosotros decidimos abordar este proyecto para apoyar con un producto de datos que cualquiera pueda ocupar para predecir si en cierta ubicación puede haber actividad de roedores, dependiendo de la información con la que se cuenta, que por suerte se alimenta diariamente.

Entregamos un análisis de los datos, además de un producto “vivo” en el que encontramos que el mejor modelo tiene un accuracy del 75%, es decir, el porcentaje de casos en los que el modelo ha acertado es casi del 75%.

Posterior a la comprensión de negocio y de acuerdo a la metodología CRISP-DM., para lograr el objetivo debemos en primer lugar hacer un análalsis exploratorio de los datos para lograr en la mayor medida posible una comprensión integral de estos. En segundo y tercer lugar, con base en la comprensión del negocio y de los datos, proponer transformaciones y evaluar el desempeño de distintos modelos. Mencionamos segundo y tercer lugar porque estos procesos los debemos realizar en conjunto. Una vez teniendo las transformaciones y el modelo final procedemos a la etapa de evaluación en la que reentrenanermos el modelo con datos de entrenamiento y prueba. Finalmente, para la parte de despliege se desarrollara un web service en flask para predecir resultados a partir de nuevos datos y un reporte ejecutivo.




FROM continuumio/miniconda3
EXPOSE 8080
COPY ./environment.yml /app/environment.yml
RUN conda env update -f /app/environment.yml
COPY . /app
RUN apt-get update && apt-get install -y jq curl

RUN awk '!/N\/A/ && !/^$/ {print}' /app/healthcare-dataset-stroke-data.csv > /app/healthcare-dataset-stroke-data-new.csv
RUN cut -d, -f2,3,4,5,6,8,9,10,11,12 /app/healthcare-dataset-stroke-data-new.csv > /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Other/0/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Female/0/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Male/1/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Yes/1/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/No/0/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Rural/0/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Urban/1/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/never smoked/0/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/formerly smoked/1/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/smokes/2/g' /app/healthcare-dataset-stroke-data-2.csv
RUN sed -i 's/Unknown/3/g' /app/healthcare-dataset-stroke-data-2.csv
# RUN ["python" "convert.py"]
RUN cat /app/healthcare-dataset-stroke-data-2.csv | python -c 'import csv, json, sys; print(json.dumps([{key: float(value) for key, value in r.items()} for r in csv.DictReader(sys.stdin)]))' > /app/datos_json.txt
RUN mkdir /app/modelos_locales
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "est_comp", "python", "/app/app.py"]

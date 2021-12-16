FROM continuumio/miniconda3
EXPOSE 8080
COPY ./environment.yml /fifa/environment.yml
RUN conda env update -f /fifa/environment.yml
COPY . /fifa
CMD ["conda", "run",  "--no-capture-output", "-n", "est_comp", "python", "/fifa/api.py"]

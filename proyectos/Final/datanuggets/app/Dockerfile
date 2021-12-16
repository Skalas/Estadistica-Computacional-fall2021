FROM continuumio/miniconda3
EXPOSE 4000
COPY environment.yml /environment.yml
RUN conda env update -f /environment.yml
COPY . /app
CMD ["conda", "run", "--no-capture-output", "-n", "datanuggets", "python", "/app/app.py"]
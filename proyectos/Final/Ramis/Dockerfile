FROM continuumio/miniconda3
EXPOSE 8080
# Replace shell with bash so we can source files
#RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -yq build-essential \
    curl \
    dos2unix \
    nano \
     && apt-get clean

COPY environment.yml  /jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct/environment.yml

RUN conda env update -f /jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct/environment.yml

COPY . /jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct/


CMD ["conda", "run", "--no-capture-output", "-n", "est_comp", "python", "/jlrzarcor-ITAM-ecomp2021-Ramis-finalprjct/api_com.py"]

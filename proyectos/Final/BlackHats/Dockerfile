FROM ubuntu:20.04
COPY . semanal

#instalo librerías necesarias de ubuntu

RUN apt update && apt upgrade -y
RUN apt install -y software-properties-common
RUN apt-get install sudo
RUN sudo apt-get install -y poppler-utils
RUN sudo apt-get install -y curl

# Instalo python

RUN apt install -y python3.9
RUN apt install -y python3-pip
RUN pip3 install -r semanal/scripts/requirements_py.txt

# Extraction

WORKDIR ../semanal/scripts


RUN chmod +x requirements.sh
RUN chmod +x compocision_carteras_sem.sh
RUN chmod +x total_carteras_sem.sh


RUN ./requirements.sh
RUN ./compocision_carteras_sem.sh 
RUN ./total_carteras_sem.sh

# Modelaje
RUN python3 modelo.py


CMD [ "python3", "./app.py" ]




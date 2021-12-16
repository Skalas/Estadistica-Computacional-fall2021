FROM python:3.7.4

RUN apt-get update

RUN apt-get -y install \
	build-essential \
	python-dev \
	python-setuptools \
    gcc \
    libc-dev \
    libpq-dev \
    g++

WORKDIR /app

COPY requirements.txt .

RUN pip install Cython --install-option="--no-cython-compile"
RUN pip install scikit-learn==0.24.1
RUN pip install -r requirements.txt

EXPOSE 5000

COPY . .
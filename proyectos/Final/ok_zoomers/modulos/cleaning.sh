#!/bin/sh

sed 's/[][]//g' /var/lib/postgresql/data1/pokemon.csv > /var/lib/postgresql/data1/clean_pokemon.csv


## sed 's/[][]//g' data/pokemon.csv > data/clean_pokemon.csv
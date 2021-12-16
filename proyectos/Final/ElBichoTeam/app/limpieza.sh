#+begin_src shell
# para sustituir sofifa_id con un id real empezamos por crear el indice
cat players_21.csv | awk -F',' -v OFS=',' 'NR == 1 {print "ID", $0; next} {print (NR-1), $0}' |
# luego quitamos la variables sofifa_id
cut --complement  -d ',' -f 2 |
# luego cambiamos de nombre id por sofifa_ida
sed -e '1s/ID/sofifa_id/' > data_cleaned.csv
# eliminando las ultimas 26 variables de la base con posiciones alternativas
cat data_cleaned.csv | awk 'NF{NF-=26}1' FS=',' OFS=',' > data_new.csv
#+end_src


#!/usr/bin/env bash

# We are about to use a code from Jeroen Janssens https://datascienceatthecommandline.com/2e/list-of-command-line-tools.html?q=dsutils#header, 
# copy it into our project to use his header function.

cp src/utils/header /usr/bin/header
chmod 777 /usr/bin/header

curl -O https://archive.ics.uci.edu/ml/machine-learning-databases/tic-mld/tic.tar.gz
tar -xvzf ./tic.tar.gz

dos2unix dictionary.txt
dos2unix ticdata2000.txt
dos2unix TicDataDescr.txt
dos2unix ticeval2000.txt

#Rows, Cols count for dataset
echo "-> Train database, Rows:" > ./TicDat_tcount.txt
wc -l ticdata2000.txt >> ./TicDat_tcount.txt
echo "Cols:" >> ./TicDat_tcount.txt
head -n1 ticdata2000.txt | grep -oE '\w+' | wc -l >> ./TicDat_tcount.txt

echo "-> Predictions database, Rows:" >> ./TicDat_tcount.txt
wc -l ticeval2000.txt >> ./TicDat_tcount.txt
echo "Cols:" >> ./TicDat_tcount.txt
head -n1 ticeval2000.txt | grep -oE '\w+' | wc -l >> ./TicDat_tcount.txt
#Headers on datasets
# RECALL: command --binary-files aids to not get a warning message

egrep --binary-files=text "^[0-9]+\s[A-Z][A-Z]+" dictionary.txt | cut -d' ' -f2 | paste -sd '\t' > train_col_h.txt
cat train_col_h.txt ticdata2000.txt | tr '\t' '|' > ticdata2000_wh.txt

egrep --binary-files=text "^[0-9]+\s[A-Z][A-Z]+" dictionary.txt | cut -d' ' -f2 | sed -n '1,85p' | paste -sd '\t' > predict_col_h.txt
cat predict_col_h.txt ticeval2000.txt | tr '\t' '|' > ticeval2000_wh.txt

#Tidy Categorcal Variables
egrep --binary-files=text "\s[see L]+[0-9]+" dictionary.txt | cut -d' ' -f2 > L_x_h.txt
egrep --binary-files=text "^[0-9]+\s[0-9]+\s[A-Z]+" TicDataDescr.txt | cut -f 2- --output-delimiter='|' | sort -t '|' -k 1n | header -a MOSTYPE"|"MOSTYPE_Desc > varcatL0.txt
egrep --binary-files=text "^[0-9]+\s[0-9]+[-]+" TicDataDescr.txt | sed 's/ /|/' | sort -t '|' -k 1n | header -a MGEMLEEF"|"MGEMLEEF_Desc > varcatL1.txt
sed -n '268,286p;287q'  TicDataDescr.txt | sed -n '1~2p' | sed 's/ /|/' | sort -t '|' -k 1n | header -a MOSHOOFD"|"MOSHOOFD_Desc > varcatL2.txt
egrep --binary-files=text "\s[0-9]+[%]" TicDataDescr.txt | sed 's/ /|/' | sort -t '|' -k 1n | header -a MGODRK"|"MGODRK_Desc > varcatL3.txt
egrep --binary-files=text "^[0-9]+\s[f]+" TicDataDescr.txt | tr -d 'f' | tr -s ' ' | sed 's/ /|/' | sort -t '|' -k 1n | header -a PWAPART"|"PWAPART_Desc > varcatL4.txt

# Add L0 a L4 categorical variable to Train Data, first sort then join
head -n 1 ticdata2000_wh.txt > aux1.txt
cat ticdata2000_wh.txt | header -d | sort -t '|' -k 1n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL0.txt --header -1 1 -2 1 -t '|' -a 1 > data_step1_ok.txt
dos2unix data_step1_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step1_ok.txt > aux1.txt
cat data_step1_ok.txt | header -d | sort -t '|' -k 4n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL1.txt --header -1 4 -2 1 -t '|' -a 1 > data_step2_ok.txt
dos2unix data_step2_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step2_ok.txt > aux1.txt
cat data_step2_ok.txt | header -d | sort -t '|' -k 5n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL2.txt --header -1 5 -2 1 -t '|' -a 1 > data_step3_ok.txt
dos2unix data_step3_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step3_ok.txt > aux1.txt
cat data_step3_ok.txt | header -d | sort -t '|' -k 6n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL3.txt --header -1 6 -2 1 -t '|' -a 1 > data_step4_ok.txt
dos2unix data_step4_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step4_ok.txt > aux1.txt
cat data_step4_ok.txt | header -d | sort -t '|' -k 44n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL4.txt --header -1 44 -2 1 -t '|' -a 1 > tab_train_ticdata.txt
dos2unix tab_train_ticdata.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt data_step1_ok.txt data_step2_ok.txt data_step3_ok.txt data_step4_ok.txt



# Add L0 a L4 categorical variable to Predictive Data, first sort then join
head -n 1 ticeval2000_wh.txt > aux1.txt
cat ticeval2000_wh.txt | header -d | sort -t '|' -k 1n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL0.txt --header -1 1 -2 1 -t '|' -a 1 > data_step1_ok.txt
dos2unix data_step1_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step1_ok.txt > aux1.txt
cat data_step1_ok.txt | header -d | sort -t '|' -k 4n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL1.txt --header -1 4 -2 1 -t '|' -a 1 > data_step2_ok.txt
dos2unix data_step2_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step2_ok.txt > aux1.txt
cat data_step2_ok.txt | header -d | sort -t '|' -k 5n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL2.txt --header -1 5 -2 1 -t '|' -a 1 > data_step3_ok.txt
dos2unix data_step3_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step3_ok.txt > aux1.txt
cat data_step3_ok.txt | header -d | sort -t '|' -k 6n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL3.txt --header -1 6 -2 1 -t '|' -a 1 > data_step4_ok.txt
dos2unix data_step4_ok.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt

head -n 1 data_step4_ok.txt > aux1.txt
cat data_step4_ok.txt | header -d | sort -t '|' -k 44n > aux2.txt
cat aux1.txt aux2.txt > aux_data.txt
join aux_data.txt varcatL4.txt --header -1 44 -2 1 -t '|' -a 1 > tab_predict_ticeval.txt
dos2unix tab_predict_ticeval.txt
rm ./aux1.txt ./aux2.txt ./aux_data.txt data_step1_ok.txt data_step2_ok.txt data_step3_ok.txt data_step4_ok.txt

cat tab_train_ticdata.txt | tr -s ',' ' ' | tr -s '|' ',' > tab_train_ticdata.csv
cat tab_predict_ticeval.txt | tr -s ',' ' ' | tr -s '|' ',' > tab_predict_ticeval.csv

dos2unix tab_train_ticdata.csv
dos2unix tab_predict_ticeval.csv

mv tab_predict_ticeval.csv src/temp/data_transfer
mv tab_train_ticdata.csv src/temp/data_transfer
mv ticdata2000_wh.txt src/temp/data_transfer
mv dictionary.txt src/temp/data_transfer

rm -f L_x_h.txt TicDat_tcount.txt TicDataDescr.txt predict_col_h.txt tab_predict_ticeval.txt tab_train_ticdata.txt tic.tar.gz ticdata2000.txt ticeval2000.txt ticeval2000_wh.txt tictgts2000.txt train_col_h.txt varcatL0.txt varcatL1.txt varcatL2.txt varcatL3.txt varcatL4.txt

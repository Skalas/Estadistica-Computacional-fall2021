#!/usr/bin/awk
BEGIN {FS = ","}
	{out_file = "data/rodent_reduced.csv"}
	{print $2","$3","$1","$6","$11","$14","$15","$17","$18 > out_file}
#!/bin/bash

# Create the table and csv files for the OAEI conference set

shopt -s nullglob
FILES=/home/dsb5/CHAIN/OAEI/conference-set-2014/*.owl

RESULT=/home/dsb5/CHAIN/OAEI/analysis-2014/

for f in $FILES
do
  echo "Processing $f file... "
  echo "$(basename "$f" .owl)"
  # Make a table of all the properties
  ~/CHAIN/code/jena/apache-jena-2.12.0/bin/arq --data $f --query oaeiPredicates.sparql >  "$RESULT"$(basename "$f" .owl)"-preds.table"
  # Make a csv file of all the properties
  ~/CHAIN/code/jena/apache-jena-2.12.0/bin/arq --data $f --query oaeiPredicates.sparql --results csv >  "$RESULT"$(basename "$f" .owl)"-preds.csv"
done



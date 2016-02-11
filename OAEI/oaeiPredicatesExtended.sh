#!/bin/bash

# Create the table and csv files for the OAEI conference set
# This version extends the query so that properties are passed on to the
# parent domain.

shopt -s nullglob
FILES=/home/dsb5/CHAIN/OAEI/conference-set-2014/*.owl

RESULT=/home/dsb5/CHAIN/OAEI/analysis-2014/

for f in $FILES
do
  echo "Processing $f file... "
  echo "$(basename "$f" .owl)"
  # Make a table of all the properties
  ~/CHAIN/code/jena/apache-jena-2.12.0/bin/arq --data $f --query oaeiPredicatesExtended.sparql >  "$RESULT"$(basename "$f" .owl)"-preds-ext.table"
  # Make a csv file of all the properties
  ~/CHAIN/code/jena/apache-jena-2.12.0/bin/arq --data $f --query oaeiPredicatesExtended.sparql --results csv >  "$RESULT"$(basename "$f" .owl)"-preds-ext.csv"
done



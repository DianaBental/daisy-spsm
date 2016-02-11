## Python CSV mode
## Diana Bental
## 3rd October 2014

# https://docs.python.org/3.3/library/csv.html

# Given a file (queryfile) that contains a query in the form
# {column:value, column:None, column:value, column:value, column:None}
# open the dataset file
# Read in all the data
# For each line in the file that matches all the column values, write out
# all the columns
# into a csv file
# or maybe a table
# and write a Prolog file to say if there was a match
# or not.

# python csvQuery.py datafile queryfile outputfile

import csv
import sys
import ast

datafile = sys.argv[1]
queryfile = sys.argv[2]
outputfile = sys.argv[3]

def perform_query(filename, query, outfile) :
    has_headers = False
    
    with open(filename) as f:
        sample = f.read(1024)
        has_headers = csv.Sniffer().has_header(sample)

    if has_headers:
        with open(filename, 'rt') as f:
            with open(outfile, 'w') as o:
                r = csv.DictReader(f, dialect='excel', skipinitialspace=True)
                for row in r:
                    match = True
                    matchline = {}
                    for key in query.keys():
                        if key in row.keys() and query[key] and row[key] != query[key]:
                            match = False
                    if match :
                        for key in query.keys():
                            if key in row.keys() :
                                matchline[key] = row[key]
                        print matchline
                        if matchline :
                            o.write(str(matchline) + "\n")
    else:
        print "This sample has no headers"

# people(height, age(21), id, name)
# query_structure = {'height': '62', 'age': '21', 'id': None, 'name': None}
# print "Query " + str(query_structure)
# print sys.argv[2]
# perform_query(sys.argv[1], query_structure)

with open(queryfile, 'r') as f:
    s = f.read()
    query_structure = ast.literal_eval(s)

print "Query " + str(query_structure)

perform_query(datafile, query_structure, outputfile)


# Given a file of terms, each of the form
# wordsInPredicate( .... )
# Split the predicate names into words
# to create terms of the form
# dataset(wordsInPredicate, ['words', 'in', 'predicate']).

# e.g.
# python splitDatasetNames.py cmt query Subject
# python splitDatasetNames.py Cocus dataset Subject

# python splitDatasetNames.py cmt query Property
# python splitDatasetNames.py Cocus dataset Property

import re
import sys

# conferenceSet = {'cmt': 'http://cmt#',
#                   'Cocus': 'http://cocus#',
#                   'Conference': 'http://conference#',
#                   'confious': 'http://confious#',
#                   'confOf': 'http://confOf#',
#                   'crs_dr': 'http://crs_dr#',
#                   'edas': 'http://edas#',
#                   'ekaw': 'http://ekaw#',
#                   'iasted': 'http://iasted#',
#                   'linklings': 'http://linklings#',
#                   'MICRO': 'http://micro#',
#                   'MyReview': 'http://myreview#',
#                   'OpenConf': 'http://openconf#',
#                   'paperdyne': 'http://paperdyne#',
#                   'PCS': 'http://pcs#',
#                   'sigkdd': 'http://sigkdd#'
#                   }                  

# # split_dataset_names('cmt')

# def split_dataset_names(filename) :
#     split_names(filename, "dataset")

# def split_query_names(filename) :
#     split_names(filename, "query")

def split_names(filename, query_or_dataset, subject_or_property) :
#    filepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasByProperty"
#    filepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasBySubject"
    filepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasBy"+subject_or_property
    # Capitalise the first letter, to construct part of the output filename
    query_or_dataset_cap = query_or_dataset[0].upper() + query_or_dataset[1:]
    outfile = "/home/dsb5/CHAIN/code/daisy-spsm/OAEI/runfiles/split"+query_or_dataset_cap+"Names.pl"
    with open(filepath, 'rt') as f:
        with open(outfile, 'wt') as o:
            for line in f :
                # Get the predicate - whatever comes before the (
                predicate = line.split('(')[0]
                # Stick a space before every capital letter
                spaced = re.sub(r'([A-Z])', r' \1', predicate)
                # Convert all to lower case
                spaced = spaced.lower()
                # Split into a list, breaking at each space
                split = spaced.split(' ')
                outline = query_or_dataset+"("+predicate+", "+str(split)+").\n"
                # print outline
                o.write(outline)

def schema_file(filename, query_or_dataset, subject_or_property) :
    filepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasBy"+subject_or_property
    # Capitalise the first letter, to construct part of the output filename
    query_or_dataset_cap = query_or_dataset[0].upper() + query_or_dataset[1:]
    outfile = "/home/dsb5/CHAIN/code/daisy-spsm/OAEI/runfiles/schemas"+query_or_dataset_cap+".pl"
    with open(filepath, 'rt') as f:
        with open(outfile, 'wt') as o:
            for line in f :
#                line = "schema"+query_or_dataset_cap+"(" + line.replace(".", ").")
                o.write("schema"+query_or_dataset_cap+"(" + line.replace(").", "))."))

filename = sys.argv[1]
query_or_dataset = sys.argv[2]
subject_or_property = sys.argv[3]
split_names(filename, query_or_dataset, subject_or_property)
schema_file(filename, query_or_dataset, subject_or_property)


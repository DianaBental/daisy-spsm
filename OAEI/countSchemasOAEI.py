## Count schemas from a set of filenameSchemasByProperty or
## fileNameSchemasBySubject files
## ~/CHAIN/OAEI/analysis-2014/
## (Schemas created by extractSchemasOAEI.py)

## Just needs to do a line count on each schema file.

## Diana Bental
## 23rd October 2014


# Running instructions:
# python -i countSchemasOAEI.py
# process_OAEI()

import sys
import ast
import re

# The names of the conference dataset and the prefixes for each file.
conferenceSet = {'cmt': 'http://cmt#',
                  'Cocus': 'http://cocus#',
                  'Conference': 'http://conference#',
                  'confious': 'http://confious#',
                  'confOf': 'http://confOf#',
                  'crs_dr': 'http://crs_dr#',
                  'edas': 'http://edas#',
                  'ekaw': 'http://ekaw#',
                  'iasted': 'http://iasted#',
                  'linklings': 'http://linklings#',
                  'MICRO': 'http://micro#',
                  'MyReview': 'http://myreview#',
                  'OpenConf': 'http://openconf#',
                  'paperdyne': 'http://paperdyne#',
                  'PCS': 'http://pcs#',
                  'sigkdd': 'http://sigkdd#'
                  }                  

# The top level - count lines in each file
def process_OAEI() :
    path = "/home/dsb5/CHAIN/OAEI/analysis-2014/"
    print path
    process_OAEI_sub(path, "Subject")
    process_OAEI_sub(path, "Property")

def process_OAEI_sub(path, SubjectOrProperty) :
    print "Count Schemas By" + SubjectOrProperty
    for filename in sorted(conferenceSet.keys()) :
        filepath = path+filename+"SchemasBy" + SubjectOrProperty
        count = 0
        with open(filepath) as f:
            for line in f:
                count = count + 1
        print filename + " " + str(count)

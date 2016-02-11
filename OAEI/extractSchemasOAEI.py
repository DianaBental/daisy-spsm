## Extract schemas and types from a set of CSV triple files
## Which have previously been extracted from a set of RDF files.
## The main call is process_OAEI_csv()
## Which creates three files from each csv file
## ...SchemasByProperty
## ...SchemasBySubject
## ...ObjectTypes

## Extracts two sorts of schemas:
# ...SchemasByProperty is in the form
# property(subject, object)
# and ...SchemasBySubject is in the form
# subject(property, property, property...)

# The second form loses the object type information.
# I could use a variant of extract_schemas_by_subject(..)
# which creates the form
# subject(property(object), property(object), property(object)...)
# but instead I create a separate type information file ...ObjectTypes
# of the form
# property(object)

## Diana Bental
## 10th October 2014

# https://docs.python.org/3.3/library/csv.html

# Running instructions:
# python -i extractSchemasOAEI
# process_OAEI_csv()

import csv
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

# The top level - for each .csv file, create schema and type files.
def process_OAEI_csv() :
    for filename in conferenceSet.keys() :
        filepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"-preds.csv"
        print filepath
        prefix = conferenceSet[filename]
        outfilepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasBySubject"
        print outfilepath
        extract_schemas_by_subject(filepath, prefix, outfilepath)
        outfilepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"SchemasByProperty"
        extract_schemas_by_property(filepath, prefix, outfilepath)
        outfilepath = "/home/dsb5/CHAIN/OAEI/analysis-2014/"+filename+"ObjectTypes"
        extract_object_types(filepath, prefix, outfilepath) 

# Given a csv file in the form subject,property,object
# create a file full of entries
# property(subject, object)
# in a Prolog-y format
def extract_schemas_by_property(filename, prefix, outfile) :
    has_headers = True  # Should be False and set by the following lines but they don't work and I don't know why, since appropriate headers do get extracted later on
    # with open(filename) as f:
    #     sample = f.read(1024)
    #     has_headers = csv.Sniffer().has_header(sample)

    if has_headers:  # Non-working test, could remove this.
        with open(filename, 'rt') as f:
            with open(outfile, 'w') as o:
                r = csv.DictReader(f, dialect='excel', skipinitialspace=True)
                for row in r:
                    # Skip rows that contain bnodes (either subject or object)
                    if not bnode(row) :
                        line = (separate_wordify(row["property"], prefix) + 
                                "(" + separate_wordify(row["domain"], prefix) + ", " +
                                separate_wordify(row["range"], prefix) +").")
                        o.write(line + "\n")
                        print line
    else:
        print "This sample has no headers"


# Given a csv file in the form subject, property, object
# (already sorted by subject)
# create a file full of entries
##  subject(property1(object1), ... propertyn(objectn)).
# subject(property1, ... propertyn).
# in a Prology format
def extract_schemas_by_subject(filename, prefix, outfile) :

    has_headers = True  # Should be False and set by the following lines but they don't work and I don't know why, since appropriate headers do get extracted later on
    # with open(filename) as f:
    #     sample = f.read(1024)
    #     has_headers = csv.Sniffer().has_header(sample)

    if has_headers:  # Non-working test, could remove this.
        with open(filename, 'rt') as f:
            current_predicate = ""
            in_predicate = False
            line = ""
            dataExists = False
            with open(outfile, 'w') as o:
                r = csv.DictReader(f, dialect='excel', skipinitialspace=True)
                for row in r:
                    # Skip rows that contain bnodes (either subject or object)
                    if not bnode(row) :
                        rdf_domain=row["domain"]
                        if rdf_domain != current_predicate :
                            if in_predicate :
                                line = line + ")."
                                print line
                                o.write(line + "\n")
                                line = ""
                            current_predicate = rdf_domain
                            in_predicate = True
                            line = separate_wordify(rdf_domain, prefix) + "("
                            dataExists = True
                        else :
                            line = line +", "
                        # Code to write property(object), ... proerty(object)
                        # line = line + separate_wordify(row["property"], prefix) +"(" + separate_wordify(row["range"], prefix) +")"
                        # code to write property, property
                        line = line + separate_wordify(row["property"], prefix)
                # At end of file - finish the last entry.
                if dataExists :
                    line = line + ")."
                    print line
                    o.write(line + "\n")
    else:
        print "This sample has no headers"


# Given a csv file in the form subject, property, object
# (already sorted by subject)
# create a file full of entries
#  property(object).
# in a Prology format.
# Prefixes from the dataset get taken off; other IRIs are left as they are.
def extract_object_types(filename, prefix, outfile) :

    has_headers = True  # Should be False and set by the following lines but they don't work and I don't know why, since appropriate headers do get extracted later on
    # with open(filename) as f:
    #     sample = f.read(1024)
    #     has_headers = csv.Sniffer().has_header(sample)

    if has_headers:  # Non-working test, could remove this.
        with open(filename, 'rt') as f:
            with open(outfile, 'w') as o:
                r = csv.DictReader(f, dialect='excel', skipinitialspace=True)
                for row in r:
                    # Skip rows that contain object bnodes (i.e. no range type)
                    if not bnode_range(row) :
                        line = (separate_wordify(row["property"], prefix) + 
                                "(" + separate_wordify(row["range"], prefix) +").")
                        o.write(line + "\n")
                        print line
    else:
        print "This sample has no headers"

# Given an rdf term and a prefix
# see if the term can be split into the prefix and the rest.
# If the term can be split then take off the prefix, format the
# rest of the word and return the formatted result.
# If the term can't be split, then quote it and otherwise return it "as is"
# Thus 
# separate_wordify("http://cocus#Approval_Email", "http://cocus#")
# returns "approvalEmail"
# while
# separate_wordify("http://www.w3.org/2001/XMLSchema#string", "http://cocus#")
# returns "'http://www.w3.org/2001/XMLSchema#string'"
def separate_wordify(rdf_term, prefix):
    result = test_separate(rdf_term, prefix)
    if result == None :
        result = "'" + rdf_term + "'"
    else: 
        result = wordify(result)
    return result

# # Split an IRI into the part that matches a prefix and something after the
# # prefix
# # If the supplied prefix doesn't match, return the whole IRI.
# def separate(rdf_term, prefix):
#     result = test_separate(rdf_term, prefix)
#     if result == None :
#         result = rdf_term
#     return result

# Test whether an IRI can be split into a part that matches a given prefix
# If so, then return what comes after the prefix
# If not then return None.
def test_separate(rdf_term, prefix):
    result = None
    splitted = rdf_term.split(prefix)
    if len(splitted) == 2 :
        result = splitted[1]
    return result


# Convert the first letter of a word to lower case
lowercase_first = lambda s: s[:1].lower() + s[1:] if s else ''

# Convert the first letter of a word to upper case
uppercase_first = lambda s: s[:1].upper() + s[1:] if s else ''

# Take a term (subject or property without the prefix) and convert it to the
# sort of format the SPSM expects.
# As fas as I know SPSM expects a set of words with no spaces or other
# characters, starting with a lower case letter and using upper case letters
# to start a new word, like this:
#     acceptPaper
#     programCommitteeMember
# Some inputs look like teh above, others more like
#    User
#    assigned_by
#    has_a_URL
#    has_a_track-workshop-tutorial_topic
#    has_startdate
#    Individual_Presentation
# So I convert these forms too
#    user, assignedBy, hasAURL, hasATrackWorkshopTutorial, hasStartdate,
#    inidividualPresentation
# respectively.
# As these answers show the results are not perfect.
# Objects can be full URIs. I really don't want to wordify those.
# This code doesn't operate sensibly on bnodes - Bnodes are filtered out
# before this code gets called.
def wordify(term) :
#    print term 
    # Divide into words, usually split by _ or -
    items = re.findall(r"[A-Za-z]+", term)
    result = ""
    if items:
        upcased = ''
        if len(items) > 1 :
            # If there is more than word, then make sure the first
            # letter of each subsequent word  is in upper case
            upcased = ''.join(map(uppercase_first, items[1:]))
        # The first (or only) word must start with a lower case letter
        result = lowercase_first(items[0]) + upcased
#    print result
    return result

# Test if a there is a bnode in the triple range or domain
# (I don't test the property because as far as I know that can't be
# a bnode)
def bnode(row) :
    return (("_:b" in row["domain"]) or ("_:b" in row["range"]))

def bnode_range(row) :
    return ("_:b" in row["range"])

def bnode_domain(row) :
    return ("_:b" in row["domain"]) 


# def bnode(line) : 
#    return ("_:b" in line)


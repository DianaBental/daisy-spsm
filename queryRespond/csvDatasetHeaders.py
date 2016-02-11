## Python CSV mode
## Diana Bental
## 3rd October 2014

# https://docs.python.org/3.3/library/csv.html

# Open a csv file; test if it has headers; if so, then obtain a list of headers
# and write them to a file in the form
# associatedPrefix('header1', '').
# associatedPrefix('header2', '').
# etc.

# python csvheaders filename outfile

import csv
import sys


def make_schema(filename, outfile) :
    has_headers = False

    with open(filename) as f:
        sample = f.read(1024)
        has_headers = csv.Sniffer().has_header(sample)

    if has_headers:
        with open(filename, 'rt') as f:
            r = csv.reader(f, dialect='excel', skipinitialspace=True)
            # Just read the first line (the headers)
            headers = r.next()
            with open(outfile, 'w') as o:
                for term in headers:
                    # associatedPrefix('term', '').
                    o.write("associatedPrefix('" + term + "', '').\n")
    else:
        print "This sample has no headers"

make_schema(sys.argv[1], sys.argv[2])


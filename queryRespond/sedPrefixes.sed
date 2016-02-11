# sed -f sedPrefixes.sed < file1 > file

# e.g.
# sed -f sedPrefixes.sed < bathingWaterLocations.csv > bathingWaterLocations.pl

# Most input lines (from file1) will look something like this:
#    locationDescription,http://data.sepa.org.uk/ont/Location#
# (i.e. the name part of an rdf-predicate name, then a comma, then
# the prefix part of the rdf-predicate)
# and they get wrapped up as a Prolog predicate, with quotes:
#    associatedPrefix('locationDescription', 'http://data.sepa.org.uk/ont/Location#').

# Delete the first line (the SPARQL variable names)
1 d

# Start the Prolog term - start each line with associatedPrefix('/
s/^/associatedPrefix('/
# s/^/$1('/  # failed attempt to paramaterise

# Put quotes before and after the comma(s)
#   This code works for any number of terms, from 1 to n, which is nice;
#   not just 2.
s/,/', '/g

# Finish the quotes and close the Prolog term.
#  Note that ARQ/Sparql gives us a weird character at the end of the line,
#  as well as an ordinary end of line, although it's only visible to
#  cat -v (not to more, emacs etc)
#  So we take off the weird end of line character and replace it with
#  closing characters for the Prolog term.
#  So this code only works for ARQ output - it isn't going to be happy
#  with other Unix input. For ordinary Unix files
# s/$/')./
#  should work instead of the following line (which does not render
#  properly with more, use emacs or cat -v to look at it)
s//')./

# Put a module delaration at the start of the file - before line 2.
# It has to be line 2 - possibly because line 1 has been deleted but
# it remembers.
## 2 i :- module(associatedPrefix, [associatedPrefix/2]).


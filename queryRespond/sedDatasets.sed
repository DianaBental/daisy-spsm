# sed -r -f sedDatasets.sed < file1 > file

# e.g.
# sed -r -f sedDatasets.sed < datasetNames.pl > deplDatasetNames.pl

# Transform a file of dataset names (as Prolog terms) into a Prolog file in
# which each dataset name is split into a list of words, and
# de-capitalised.
# At present we just assume that words boundaries are indicated by
# capital letters though we could split at other character boundaries.

# Most input lines (from file1) will look something like this:
# dataset(bathingWaterLocations).
# or maybe
# dataset('BathingWaterLocations').
# And we want them split into words like this
# dataset('BathingWaterLocations', [bathing, water, locations]).

# Wrap in square brackets
# This is the bit that needs the -r option for sed. For whatever reason.
# s/\(/\([/  
# s/\)/])/
s/\((.*)\)/(\1, [\1])/

# testing - repace anything in sqaure brackets by pussycat
# s/\[(.*)\]/pussycat/

## # Remove any single quotes in the square brackets
# s/'//g
# There may be a pair just inside the square brackets,
s/\['/\[/
s/'\]/\]/

## # Put comma and space before any capital letters
## s/([A-Z])/, \1/g
s/(\[.*)([A-Z])/\1, \L\2/

# I can't justify this. Except that it works. It splits the word inside the
# square brackets up into separate words separated by commas. The
# uppercase letters that indicate the start of a new word are replaced
# by lower case, too.
# It works so long as the word doesn't have more than 9 components.
# Vile. I should be ashamed, and I am. I should do this
# properly, in Perl or Python.
# If the line is too long then capital letters may remain; so the list
# will not be ground Prolog. Any Prolog that uses the results should first
# test for ground on each term.
s/(\[.*)([A-Z])(.*,)/\1, \L\2\3/
s/(\[.*)([A-Z])(.*,)(.*,)/\1, \L\2\3\4/
s/(\[.*)([A-Z])(.*,)(.*,)(.*,)/\1, \L\2\3\4\5/
s/(\[.*)([A-Z])(.*,)(.*,)(.*,)(.*,)/\1, \L\2\3\4\5\6/
s/(\[.*)([A-Z])(.*,)(.*,)(.*,)(.*,)(.*,)/\1, \L\2\3\4\5\6\7/
s/(\[.*)([A-Z])(.*,)(.*,)(.*,)(.*,)(.*,)(.*,)/\1, \L\2\3\4\5\6\7\8/
s/(\[.*)([A-Z])(.*,)(.*,)(.*,)(.*,)(.*,)(.*,)(.*,)/\1, \L\2\3\4\5\6\7\8\9/

# Remove any commas and spaces that we might have put right after the open bracket
s/\[, /[/

## # Change all upper to lower case.
# This is now done in a oner, inside the square brackets above.
## s/(.*)/\L\1/g







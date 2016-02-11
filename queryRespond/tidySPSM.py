# Diana Bental
# 28th November  2014

# python tidySPSM.py result.txt result.pl

# Given a result file from spsm, tidy it up into Prolog format.

# Try to tidy up the output from SPSM.
# SPSM has unpredictable habits when it comes to nesting its outputs.
# Sometimes the square brackets don't balance correctly
# which means Prolog can't read them.
# Sometimes there are extra square brackets round a parameter, for no
# obvious reason.
# This code creates balanced brackets with no extra.
# This is only a patch for the problem, not a reliable fix.
# It depends on there being a very shallow level level of matching - either
# the predicate alone or the predicate plus one parameter.
# This is true for CHAIN at present but may not be true in future.
# It also quotes all names which are Prolog atoms, in case any start with
# a captal letter.

# The format of a word may be wrong. Words can only be alpahnumeric.
# But rdf terms can contain other symbols, like # or :
# And csv terms can contain spaces

# Note the extra brackets round [activity] - which is actually a right bracket short

# similarity(0.042857142857142816).
# match(none).
# match([[bathingWater],<,[waterBodyPressures]]).
# match([[bathingWater,catchment],<,[waterBodyPressures,[activity]]).
# match([[bathingWater,localAuthority],<,[waterBodyPressures,affectsGroundwater]]).

# and sometimes it adds an extra right paren where there is no need for one
# Like this -ish
# match([[bathingWater,localAuthority],<,[waterBodyPressures,affectsGroundwater]]]).
# but sometimes it needs that third bracket to balance things, and deleting it
# causes a problem.

# [^,\]]  - should match any character except , or ]

# \[[^,\]]+\] - left bracket followed by chars (not ,]) followed by ]
# \[[^,\]]+, - left bracket followed by chars (not ,]) followed by ,
# ,[^,\]]+,  - comma followed by chars (not ,]) followed by ,
# ,[^,\]]+\]  - comma followed by chars (not ,]) followed by ]

# replaces 'foobar' with 'foo123bar'
# re.sub(r'(foo)', r'\g<1>123', 'foobar')

# Also exlude existing single quotes ' from pattern - so that the patterns
# don't override each other

# [foo] -> ['foo']
# re.sub(r'(\[)([^,\]]+)(\])', r"\g<1>'\g<2>'\g<3>", '[foo,baz],>[me,you]')
# re.sub(r'(\[)([^,\]]+)(\])', r"\g<1>'\g<2>'\g<3>", '[foo],>,[me]')
# [foo, -> ['foo',
# re.sub(r'(\[)([^,\]]+)(,)', r"\g<1>'\g<2>'\g<3>", '[foo,baz],>[me,you]')
# ,foo, -> ,'foo',
# re.sub(r'(,)([^,\]]+)(,)', r"\g<1>'\g<2>'\g<3>", '[foo,baz,bar],>,[me,you,he]')
# ,foo] -> ,'foo']
# re.sub(r'(,)([^,\]]+)(\])', r"\g<1>'\g<2>'\g<3>", '[foo,baz,bar],>,[me,you,he]')

import re
import sys

# a =  '[foo,baz,bar],>,[me,you,he]'
# b = re.sub(r"(\[)([^,\]']+)(\])", r"\g<1>'\g<2>'\g<3>", a)
# c = re.sub(r"(\[)([^,\]']+)(,)", r"\g<1>'\g<2>'\g<3>", b)
# d = re.sub(r"(,)([^,\]']+)(,)", r"\g<1>'\g<2>'\g<3>", c)
# e = re.sub(r"(,)([^,\]']+)(\])", r"\g<1>'\g<2>'\g<3>", d)

# The pattern for matching a single predicate
# e.g.
# match([[bathingWater],<,[waterBodyPressures]]).
# The point here is not to count the square brackets. One or more is enough.
# So the pattern is roughly this:
# word([word],>,[word]).
# where word can contain any alphanumerics, and [ and ] can be any number of []
#single_pred_patt = re.compile('(^\w+)\(\[+(\w+)\]+,([=><]),\[+(\w+)\]+\)\.')
single_pred_patt = re.compile('(^[\w\s]+)\(\[+([\w\s]+)\]+,([=><]),\[+([\w\s]+)\]+\)\.')

# Pattern for matching a line with the predicate and one parameter
# e.g.
# match([[bathingWater,catchment],<,[waterBodyPressures,[activity]]).
# match([[bathingWater,localAuthority],<,[waterBodyPressures,affectsGroundwater]]).
# param_pred_patt= re.compile('(^\w+)\(\[+(\w+),(\w+)\]+,([=><]),\[+(\w+),\[*(\w+)\]+\)\.')
param_pred_patt= re.compile('(^[\w\s]+)\(\[+([\w\s]+),([\w\s]+)\]+,([=><]),\[+([\w\s]+),\[*([\w\s]+)\]+\)\.')

other_match_patt= re.compile('^match\(')

infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile) as f:
    with open(outfile, 'w') as out:
        for line in f:
            #        print line.strip()
            matched = single_pred_patt.match(line)
            if(matched) :
                # Predicate only
                ## Debug - show the whole original pattern
                ## print matched.group()
                # The tidied pattern
                # Give it the right number of brackets, and put all the terms
                # in single quotes to avoid grief with Prolog variables
                out.write(matched.group(1) + "([['"  + matched.group(2) + "'],"
                          + matched.group(3) +   # The operator = > or <
                          ",['" + matched.group(4) + "']]).\n")
            else :
                matched = param_pred_patt.match(line)
                if(matched) :
                    # Predicate and one parameter
                    ## Debug - show the whole original pattern
                    ## print matched.group()
                    # The tidied pattern
                    # Give it the right number of brackets, and put all the terms
                    # in single quotes to avoid grief with Prolog variables
                    out.write(matched.group(1) + 
                              "([['" + matched.group(2) + "','" + 
                              matched.group(3) + "'],'" + 
                              matched.group(4) +    # The operator = > or <
                              "',['" + matched.group(5) + "','" + 
                              matched.group(6) + "']]).\n")
                else :
                    # It is a match, but not one to one or two to two.
                    # Put quotes round individual words in other patterns
                    #  This deals with single items that get split
                    # into multiple items - the other patterns don't match
                    matched = other_match_patt.match(line)
                    if(matched) :
                        new = re.sub(r"(\w+)", r"'\g<1>'", line)
                        out.write(new)
                    else :
                        # Anything else, such as significance - write it straight out again.
                        out.write(line)


# Set some directory variables;
# Then start Prolog.

# Jena ARQ directory.
export ARQROOT=/home/dsb5/CHAIN/code/jena/apache-jena-2.12.0
export PATH="${ARQROOT}/bin:${PATH}"

#Locate the DAISY components
export DAISY_HOME=/home/dsb5/CHAIN/code/daisy-spsm

#Locate the DAISY SAQ components
export DAISY_SAQ="${DAISY_HOME}/SAQ"

# Switches for the target schemas and prefixes - either hand written (hand) or
# auto-generated from dbpedia (full)
# Poinjts to dfferent schema and prefix files in the "target" direectory
# export DAISY_TARGET_TYPE="hand"
export DAISY_TARGET_TYPE="full"

# Switches for the queries - either SAQ or resolved
# Points to different files n the queries/querynn directory
export QUERY_TYPE="saq"
# export QUERY_TYPE="resolved"

# The combination of DAISY_TARGET_TYPE and QUERY_TYPE points to a directory in
# each queries/querynn/ directory which will contain the results.txt file
# for that combo of query, query type and target type.

# A file for the prefixes and one for schemas.
export DAISY_PREFIXES="${DAISY_SAQ}/target/${DAISY_TARGET_TYPE}_prefixes.pl"
export DAISY_TARGET_SCHEMAS="${DAISY_SAQ}/target/${DAISY_TARGET_TYPE}_schemas.pl"

# old, hopefully unused.
export DAISY_TARGET="xxxxx/target"

# Are we looking at Sparql (n3) dataset files, or csv dataset files?
export DAISY_FILETYPE="n3"
# export DAISY_FILETYPE="csv"

# The target URI
export TARGET_URI="http://dbpedia.org/sparql"

# Directory for temporary files generated by the system as it runs
export DAISY_RUNFILES="${DAISY_SAQ}/runfiles"

#for file in query01 query02 query03 query04 query05 query06
#for file in query08 query10 query11 query12 query14 query15
#for file in query16 query17 query18 query19 query20 query21
#for file in query22 query23 query24 query25 
#for file in query27 query28 query29 query30
for file in query01 query02 query03 query04 query05 query06 query08 query10 query11 query12 query14 query15 query16 query17 query18 query19 query20 query21 query22 query23 query24 query25 query27 query28 query29 query30
do
    # Delete all the temporary files (except the SPSM ones)
    rm $DAISY_RUNFILES/*
    
    export DAISY_QUERY="${DAISY_SAQ}/queries/${file}/${QUERY_TYPE}.pl"
    
    # Put the output file in the same place
    export DAISY_OUTPUT="${DAISY_SAQ}/queries/${file}/result_${QUERY_TYPE}_${DAISY_TARGET_TYPE}"
    # export DAISY_OUTPUT="${DAISY_QUERY}"
    
    echo $DAISY_OUTPUT
    
    # SICSTUS version
    #sicstus --noinfo -l SAQProcesses.pl 
    # SWI-Prolog version
    #pl -s SAQProcesses.pl
    # SWI-Prolog version - run the top-level query and then halt
    # Useful for bulk execution.
    pl -g respond_to_query,halt -s SAQProcesses.pl
done
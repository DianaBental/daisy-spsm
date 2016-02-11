# Set some directory variables;
# Then start Prolog.

# Jena ARQ directory.
export ARQROOT=~/CHAIN/code/jena/apache-jena-2.12.0
export PATH="${ARQROOT}/bin:${PATH}"

#Locate the DAISY components

export DAISY_HOME=~/CHAIN/code/daisy-spsm

#Locate the DAISY demo components
export DAISY_DEMO="${DAISY_HOME}/demo"

# Query file directory
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/query1"

# Directory with target data files
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"

# Directory with source data files (related to the query, used to extract
# the prefixes related to the query)
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# Are we looking at Sparql (n3) dataset files, or csv dataset files?
export DAISY_FILETYPE="n3"
# export DAISY_FILETYPE="csv"

# Are we running interatively with pauses - e.g. for a demo?
# Comment this out for a big batch run
export DAISY_RUN_TYPE="interactive"

# Other test combinations of query, target dataset and source dataset

# (test based on EUStatistics/freshWaterResources)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/test"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# I would have expected this example to use the EUStatistics dataset 
# for its source data but the query file has a predicate water() and
# there isn't a water.n3 in the EUStatistics dataset. Uses
# demo_dataset/water.n3 as its source file.
export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/EUStatistics/freshWaterResources"
export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# query1
# An example, dervied as a variation of SEPA data, run over the SEPA datasets
# (uses demo-dataset/surfaceWaterBodies.n3, a cut-down file from SEPA
# in which the original SEPA column subBasinDistrict was replaced by
# subBasinArea)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/query1"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# query2
# An example, dervied as a variation of SEPA data, run over the SEPA datasets
# (uses demo-dataset/bathingWater.n3)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/query2"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# SPA
# This query shows one of the issues with RDF: what happens if no 
# single entity contains all the parameters in the query. Two queries are
# generated but one returns no data for this reason.
# (uses demo-dataset/water.n3)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/SPA"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# UK Environment Agency
# I don't have the source dataset for this query, so I have faked up
# a file in demo-dataset/uk_BathingWaters.n3 (to extract source prefixes)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/uk Environment Agency"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/sepa"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# NAPTAN
# I don't have the source dataset for this query, so I have faked up 
# a file in demo-dataset/stopAvailability.n3 (to extract source prefixes)
# This example fails on the SEPA  and datasets becaue it can't find a
# corresponding dataset name in either one - not even 
# EUStatistics/transportNetwork.n3
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/NAPTAN"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/EUStatistics"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/demo-dataset"

# EU Statistics
# This query is derived indirectly from the EUStatistics dataset.
# For example datasets/EUStatistics/environmentProtectionRegions.n3
# has geo and unit properties. But EnvironmentDomain and EnvironmentExposure
# correspond to properties env_dom and env_exp, and Dimension corresponds to
# part of a property prefix and not a property name. So this query doesn't
# work at all well, not even on EUStatistics data.
# (For this query, the target directory can just as well be the same as the
# source)
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/EUStatistics/environmental Protection expendituture regions"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/EUStatistics"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/EUStatistics"

# A CSV example
# export DAISY_QUERY="${DAISY_HOME}/queryRespond/queries/testcsv"
# export DAISY_TARGET_DATA="${DAISY_HOME}/queryRespond/datasets/csvtargets"
# export DAISY_SOURCE_DATA="${DAISY_HOME}/queryRespond/datasets/csvsource"
# export DAISY_FILETYPE="csv"

# Directory for temporary files generated by the sysem as it runs
export DAISY_RUNFILES="${DAISY_HOME}/queryRespond/runfiles"

# Directory for the main output file generated by the sysem
export DAISY_OUTPUT="${DAISY_DEMO}"

# Delete all the temporary files (except the SPSM ones)
rm $DAISY_RUNFILES/*

echo $DAISY_QUERY/query.pl

# SICSTUS version
#sicstus --noinfo -l callProcesses.pl 
# SWI-Prolog version
# pl -s callProcesses.pl #old HW installation, out of date
swipl -g respond_to_query -s callDemoProcesses.pl 

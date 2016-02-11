% In this module we can create files which contain:
% The query dataset name, and a version split into different words
% All the target dataset names, and a version split into different words
% All the (property) prefixes from the source file
% All the (property) prefixes from a target file
% Create a schema from a target file - also creates and loads the prefixes
:- module(handleDatasetNames, [
	      make_query_names_file/2,
	      make_source_prefixes/2,
	      make_target_names_file/3,
	      make_target_prefixes/2,
	      make_target_schema/3,
	      load_source_prefixes/0,
	      load_prefixes/1,
	      split_dataset_names/3]
	 ).

% :- use_module(library(system3)). % SICSTUS
:- use_module(library(lists)).

:- use_module('utils.pl').

% Create a file that contains the query file name (i.e. the predicate or 
% source dataset) 
% in the form dataset(name).
% and a file in which the name has been split into words
% in the form dataset([n1, n2, ...]).
%
% make_query_names_file(+Query, -SplitNames)
%
% Returning the QueryDatasetName and SplitNames structures here
% means we can keep them in memory and we don't have to worry about
% consulting temp files later.
make_query_names_file(Query, SplitNames) :-
    Query =.. [QuerySource|_Rest],
    runfiles_path('queryNames.pl', QueryNamesPath),
    open(QueryNamesPath, write, QS),
    write_dataset_lines([QuerySource], QS),
    close(QS),

    SplitQueryNames = 'splitQueryNames.pl',
    runfiles_path(SplitQueryNames, SplitQueryNamesPath),

    % Create the file of split query names.
    split_dataset_names(QueryNamesPath, SplitQueryNamesPath, 
			'Parse the query dataset name:'),
    reconsult_runfile(SplitQueryNames),
    setof(dataset(Name, Names),
	  dataset(Name, Names),
	  SplitNames).

% The module system requires this.
dataset(Name, GroundNames) :- utils:dataset(Name, Names),
			ground_filter(Names, GroundNames).

% Remove any unbound words from the list.
% A very long name could result in an unbound variable in the
% names list (blame my sed scripting) so we filter it (them) out.
%
% ground_filter(+List, -GroundList)
ground_filter([], []) :- !.
ground_filter([H|T], [H|F]) :- ground(H), !, ground_filter(T, F).
ground_filter([H|T], F) :- ground(H), !, ground_filter(T, F).

% Split each dataset name in the dataset names file into a list of names
split_dataset_names(InFile, OutFile, Mesg) :-
    environment_variable('DAISY_HOME', DaisyHome),
    atom_concat(DaisyHome, '/queryRespond/sedDatasets.sed', Sed),
    atoms_concat(['sed -r -f ', Sed, ' < ', InFile, ' > ', OutFile], 
    		 SedSh),
    system_instruction(silent, [SedSh]),
%    system_instruction([SedSh]),    
    nl, write(Mesg), nl,
    %    system_instruction(silent, ['cat ', OutFile]).
    system_instruction(silent, ['head -n 20 ', OutFile]).    

% Write a list of terms (atoms) to an open stream, each wrapped up in the form
% dataset('term').
% write_dataset_lines(+Terms, +Stream)
write_dataset_lines([], _DS) :- !.
write_dataset_lines([H|T], DS) :-
    write(DS, 'dataset('), writeq(DS, H), write(DS, ').'), nl(DS),
    write_dataset_lines(T, DS).

% Make a file full of prefixes from the source dataset.
% make_source_prefixes(+Dataset)
make_source_prefixes(TargetFilesType, Dataset) :-
    source_data_path(Dataset, Path), % in the source directory
    make_prefixes(TargetFilesType, 'sourceXXX', Path). % The source prefixes get a unique filename

% Make a file full of prefixes from the target dataset.
% make_target_prefixes(+Dataset)
make_target_prefixes(TargetFilesType, Dataset) :-
    target_data_path(Dataset, Path), % in the target directory
    make_prefixes(TargetFilesType, Dataset, Path).

% Inspect the dataset file (n3 or csv) and put the columns (rdf-predicates)
% into a file called prefixes_<dataset>.pl.
% If it's an n3 datafile then use ARQ and the rdf-predicates are split up into
% the IRI and the last word.
% IF it's a csv file then use Python and the IRI is null.
make_prefixes(TargetFilesType, DataSet, DataPath) :-
    atoms_concat([DataPath, '.', TargetFilesType], DataFile), % look for an .n3 file
% Demo    nl, write(DataSet), nl,
    write('Extract schema and prefixes '), nl,
    write(DataFile), nl,
    atoms_concat(['prefixes_', DataSet, '.pl'], PLFile),
    runfiles_path(PLFile, PLPath),
    make_prefixes_sub(TargetFilesType, DataSet, DataFile, PLPath),
    reconsult_runfile(PLFile),  % Read in the formatted prefixes
    setof(Prefix, End^associatedPrefix(End, Prefix), Prefixes),
    nl, write('Found rdf prefix(es):'), nl,
    write_list(Prefixes),
    setof(Name, Prefix^associatedPrefix(Name, Prefix), Names),
    nl, write('Found column name(s) for schema:'),
    write(DataSet), write(Names),
    nl.

make_prefixes_sub(csv, _DataSet, CSVPath, PLPath) :-
    % Get the Python program that creates the headers file
    environment_variable('DAISY_HOME', DaisyHome),
    atom_concat(DaisyHome, '/queryRespond/csvDatasetHeaders.py', Python),
    % Write output to PLPath (to be reconsulted)
    %     system_instruction(['python ', Python, ' ', CSVPath, ' ', PLPath]).
    system_instruction(silent, ['python ', Python, ' ', CSVPath, ' ', PLPath]).    


make_prefixes_sub(n3, DataSet, N3Path, PLPath) :-
    environment_variable('DAISY_HOME', DaisyHome),
    atom_concat(DaisyHome, '/queryRespond/predicatePrefixes.sparql', SparqlQuery),
    atoms_concat(['prefixes_', DataSet, '.csv'], CSVFile),
    runfiles_path(CSVFile, CSVPath),
    atoms_concat(['arq --data ', N3Path,
		  ' --query ', SparqlQuery,
		  ' --results csv > ', CSVPath], Query),
    %Demo    system_instruction([Query]),  % Execute the query
    system_instruction(silent, [Query]),  % Execute the query    
% arq --data DataFile --query Sparql --results csv > prefixes.csv
% ~/CHAIN/code/jena/apache-jena-2.12.0/bin/arq 
% --data ~/CHAIN/code/daisy-spsm/queryRespond/datasets/sepa/classifications-shorter.n3
% --query predicatePrefixes.sparql
% --results csv
    % sedPrefixes.sed contains the sed script to convert to the
    % query result from csv into a Prolog format
    atom_concat(DaisyHome, '/queryRespond/sedPrefixes.sed', Sed),
    atoms_concat(['sed -f ', Sed, ' < ', CSVPath, ' > ', PLPath], 
		 SedSh),
    %    system_instruction([SedSh]).  % Execute the formatting script
    system_instruction(silent, [SedSh]).  % Execute the formatting script    

% associatedPrefix(?Name, ?Prefix)
%
% Necessary for the modules system - associatedPrefix gets loaded
% into the utils module.
associatedPrefix(Name, Prefix) :- utils:associatedPrefix(Name, Prefix).

% Create the file of target dataset names.
%
% This is the sisctus way of getting the n3 fle names - there is a
% simpler way in straight SWI Prolog.
%
% Get all the n3 filenames from the (target) data directory
% strip off the .n3 extension
% and write them to a file for later processing.
% We could just assert them straight into the database, but hey ho.
% After this file has been created, create a file in which the name of each
% dataset has been split into words.
%
% make_target_names_file(+Type, -DatasetNames, -SplitNames)
%
% Returning the dataset names and split names here means we don't have to
% worry about consulting temp files later on.
%
% The format of the SplitNames is expected to be along the lines of:
% [dataset(surfaceWaterBodies, [surface, water, bodies]),
%  dataset(bathingWaters, [bathing, waters])... ]
%
make_target_names_file(Type, Files, SplitNames) :-
    % Create the file of dataset names
    environment_variable('DAISY_TARGET_DATA', DataDirectoryPath),
    write('Using potential target datasets in: '), write(DataDirectoryPath), nl,
    append_to_output(['Use target datasets: ', DataDirectoryPath]),
    get_directory_files(DataDirectoryPath, AllFiles),
    filter_names(Type, AllFiles, Files),
    write(Files), nl,
    append_to_output(Files),

    runfiles_path('datasetNames.pl', DatasetNamesPath),
    open(DatasetNamesPath, write, DS),
    (write_dataset_lines(Files, DS) ;
     true),
    close(DS),

    SplitDatasetNames = 'splitDatasetNames.pl',
    runfiles_path(SplitDatasetNames, SplitDatasetNamesPath),

    % Create the file of split dataset names.
    split_dataset_names(DatasetNamesPath, SplitDatasetNamesPath, 
			'Parsed names of target datasets:'),
    reconsult_runfile(SplitDatasetNames),
    setof(dataset(Name, Names),
	  dataset(Name, Names),
	  SplitNames).

filter_names(csv, Names, Filtered) :- csv_only(Names, Filtered).
filter_names(n3, Names, Filtered) :- n3_only(Names, Filtered).

% Get the names of all files that end in .n3, without the n3,
% and ignore all files that don't.
% n3_only(+N3Names, -StrippedNames)
n3_only([], []).
n3_only([N3Name|Files], [Name|Names]) :-
    n3_name(N3Name, Name),  % return an n3 name with no extension
    !,
    n3_only(Files, Names).
n3_only([_|Files], Names) :-
    n3_only(Files, Names).  % ignore if it isn't an n3 name

% Get the names of all files that end in .csv, without the csv,
% and ignore all files that don't.
% csv_only(+CSVNames, -StrippedNames)
csv_only([], []).
csv_only([CSVName|Files], [Name|Names]) :-
    csv_name(CSVName, Name),  % return an csv name with no extension
    !,
    csv_only(Files, Names).
csv_only([_|Files], Names) :-
    csv_only(Files, Names).  % ignore if it isn't an csv name

% [46,110,51] = '.n3'
% Test the name to see if it ends in .n3, if so return the name without the
% extension, otherwise fail.
% n3_name(+N3Name, -Name) :-
n3_name(N3Name, Name) :-
    atom_codes(N3Name, String),
    %reverse the name, pick off and match the last 3 characters
    reverse(String, [51, 110, 46 | Rest]),
    % and if they match then the rest of the string is the filename
    reverse(Rest, NameString),
    atom_codes(Name, NameString).

% [46,99,115,118] = '.csv'
% Test the name to see if it ends in .csv, if so return the name without the
% extension, otherwise fail.
% csv_name(CSVName, -Name) :-
csv_name(CSVName, Name) :-
    atom_codes(CSVName, String),
    %reverse the name, pick off and match the last 4 characters
    reverse(String, [118, 115, 99, 46 | Rest]),
    % and if they match then the rest of the string is the filename
    reverse(Rest, NameString),
    atom_codes(Name, NameString).

% make_target_schema(+TargetFilesType, +TargetDataset, -Schema)
%
% Given the name of a single target dataset, return a schema for it
% in the form: TargetDataset([ColumnName1, ColumnName2...])
% e.g. make_target_schema(n3, waterBodyPressures, Schema)
% binds Schema to
% waterBodyPressures([activity, activityCode, affectsGroundwater, ....])
%
% Since this code calls make_target_prefixes, as a side effect it also
% creates and reconsults the table of rdf:prefixes associated with each colum.
make_target_schema(TargetFilesType, TargetDataset, Schema) :-
    % nl, write('Extract schema from '), write(TargetDataset), nl,
    make_target_prefixes(TargetFilesType, TargetDataset),
    setof(Column, Prefix^associatedPrefix(Column, Prefix), Columns),
    Schema =.. [TargetDataset|Columns].
%    nl, write(Schema), nl.

% load_prefixes(+Dataset)
% load_source_prefixes.
%
% Load all the prefixes for a given dataset, or for source dataset
% Assumes the file of prefixes has already been created for the dataset
% (i.e. by an earlier call to make_source_prefixes or make_target_prefixes)
load_source_prefixes :- 
    write('Load source prefixes'), nl,
    reconsult_runfile('prefixes_sourceXXX.pl').

load_prefixes(Dataset) :-
    write('Load prefixes for '), write(Dataset), nl,
    atoms_concat(['prefixes_', Dataset, '.pl'], PrefixFile),
    reconsult_runfile(PrefixFile).

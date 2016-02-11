:- module('SAQDemoProcesses', [respond_to_query/0]).

% :- use_module(library(system3)). % SICSTUS
:- use_module(library(lists)).

:- use_module('../SAQ/translation.pl').
:- use_module('../SAQ/repair.pl').

:- use_module('../queryRespond/handleDatasetNames.pl').
:- use_module('../queryRespond/utils.pl').
:- use_module('../queryRespond/spsmMatch.pl').
:- use_module('../queryRespond/wordnetSearch.pl').
:- use_module('../queryRespond/sumoSearch.pl').
:- use_module('../queryRespond/narrowDatasets.pl').

% Dangerous but this stops SICSTUS from complaining and pausing the run
% whenever dynamically
% created data is reconsulted. This flag doesn't seem to affect SWI Prolog
% which just prints a warning and carries on.
:- set_prolog_flag(redefine_warnings, off).

% The file type is set in translation.sh, either n3 or csv are known types
respond_to_query :-
    environment_variable('DAISY_FILETYPE', TargetFilesType),
    respond_to_query(TargetFilesType).

respond_to_query(TargetFilesType) :-
    new_output,
    environment_variable('DAISY_QUERY', QueryFile),    
%    write('Query File: '), write(QueryFile), nl,
    open(QueryFile, read, QF),
    read(QF, QueryTerm),
    close(QF),
    nl,
    write('Incoming query: '), writeq(QueryTerm), nl,
    nl,
    append_to_output(['Query: ', QueryTerm]),

    write_heading(['Try the initial query on the target dataset']),
    wait_for_user,    
    load_local_prefixes,
    start_translation(TargetFilesType, QueryTerm, Success),

    wait_for_user, 
    handle_query_result(Success, TargetFilesType, QueryTerm).

%% handle_query_result(success, _TargetFilesType, _QueryTerm) :- !. % Do nothing, we've won.
handle_query_result(_NotSuccess, TargetFilesType, QueryTerm) :-
    write_heading(['Query repair']),
    nl, write('Make query schema'), nl,
    make_query_schema(QueryTerm, QuerySchema),
    write('Query schema: '), writeq(QuerySchema), nl, nl,
    wait_for_user,
    write_heading(['Expand the query schema to find relevant datasets']),

    % store the query dataset filename and a version split into words
    make_query_names_file(QuerySchema, [dataset(QueryName, SplitQueryNames)]),

    nl, write('Use Wordnet to find associated terms'), nl,
    wait_for_user,
    connect_list_to_words(SplitQueryNames, WordnetAssociatedTerms),
    nl, write('WordNet expanded the query dataset \''), write(QueryName), write('\' to '), nl, write(WordnetAssociatedTerms), nl,
%    nl, write('Trace Wordnet Test'), nl, 
%    connect_list_to_words([water, body, measures], WNTest),
%    write(WNTest), nl,
    wait_for_user,
    nl, write('Use the Sumo ontology to find relevant terms'), nl,
    sumo_connection(SplitQueryNames, SumoRelatedWordSets),
    nl, write('Sumo expanded the query dataset \''), write(QueryName), write('\' to '), nl, write(SumoRelatedWordSets), nl,
    wait_for_user,
    write_heading(['Identify target datasets related to the query']),
    wait_for_user,     
    % Now get all the dataset names.
    nl, write('Available target dataset names:'), nl,
    load_target_schemas,
    setof(TargetSchema,
	  T^(utils:target(T), make_query_schema(T, TargetSchema)),
	  TargetSchemas),
    length(TargetSchemas, L),
    nl, write('Found '), write(L), write(' potential datasets in total:'), nl,
    write_list(TargetSchemas, 20), nl,
    wait_for_user, 
    make_target_names(TargetSchemas, SplitTargetNames),
    
    nl, write('Narrowing the datasets to choose ones related to query'), nl,
    wait_for_user,
    narrow_datasets(SplitTargetNames, WordnetAssociatedTerms, SumoRelatedWordSets, Datasets),
    nl, write('Narrowed to these target datasets: '), write(Datasets), nl,
    append_to_output_nl(['Narrowed to these target datasets: '|Datasets]),
    wait_for_user,
    write_heading(['Select schemas for the target datasets']),
    make_target_candidates(Datasets, TargetSchemas, Candidates),
    wait_for_user,     
    nl, write('Schemas for the selected (narrowed) datasets are: '), nl,
    write_separated_list(Candidates), nl,
    wait_for_user,     
    write_heading(['Use SPSM to match the query and selected target schemas']),
    rank_matches(QuerySchema, Candidates, Maps), %SPSM
    repair_schema(QueryTerm, QuerySchema, Maps, NewSchemaQueries),
    wait_for_user,     
    write_heading(['Try the mapped queries.']),
    try_mapped_queries(NewSchemaQueries, TargetFilesType).

% try_mapped_queries(+Queries, +TargetFilesType)
%
% Try a set of queries (which have been generated by the schema repair
% process), one at a time.
% We try *all* the possible schema repairs. 
% If a query initially fails due to no matching data, make data repairs
% and try again. 
% For each schema repair we may do several data repairs, but we stop
% doing data repairs as soon as we find one that returns some data; and we
% move on to the next schema repair.
try_mapped_queries([], _) :- !.
try_mapped_queries([Query|Queries], TargetFilesType) :-
    % Do the query
    try_query(TargetFilesType, Query, Success),
    % Do we need to do data repairs? If so, do them until something matches.
    consider_data_repair(TargetFilesType, Query, Success),
    % Do another query
    try_mapped_queries(Queries, TargetFilesType).

% Run a single query.
try_query(TargetFilesType, Query, Success) :-
    wait_for_user,    
    start_translation(TargetFilesType, Query, Success),
    !. % Only try a query once. Do not fail back into this. 

% Do data repairs until one of them succeeds and returns some data
% (or there are no more possible data repairs.)
%
% It's only worth doing data repair if the query operated successfully but
% it returned no data. If it succeeded (i.e. it returned data) or failed
% altogether then data repair is not appropriate.
consider_data_repair(TargetFilesType, Query, no_data) :- 
    % Generate a possible data repair.
    % If try_query fails, repair_data may retry and generate other repairs.
    repair_data(Query, NewQuery),
    try_query(TargetFilesType, NewQuery, success).
consider_data_repair(_, Query, no_data) :- 
    !,
    % We know all the columns exist, and we already tried a data repair
    % with all the columns uninstantiated. So this situation shouldn't
    % arise in most datasets.
    % But it could arise in an n3 file if no single record has data
    % in all the columns that appear in the query.
    % I suppose repair_data could deal with it by dropping
    % columns from the query until some combo matches - but I haven't.
    write_heading(['No data for query ', Query]).
consider_data_repair(_Type, _Query, success) :- !.
consider_data_repair(_Type, _Query, failure) :- !.

% repair_schema(+QueryTerm, +QuerySchema, +Mappings, -NewQueries)
%
% The schema repair process.
% Generate replacement queries using the schema Mappings.
% QuerySchema doesn't actually get used but it's handy for reporting.
% The replacement is done directly on the QueryTerm to create a
% set of new query terms in which the dataset and column names have been
% replaced. If there are any values for any of the columns, these are
% maintained unchanged in the new queries.
repair_schema(QueryTerm, QuerySchema, [], _) :-
    !,
    append_to_output_nl(['No matches found for ', QuerySchema]),
    append_to_output_nl(['Cannot respond to  ', QueryTerm]),
    nl, write('No matches found for '),
    write(QuerySchema), nl,
    write('Cannot respond to '),
    write(QueryTerm), nl,
    halt.
repair_schema(QueryTerm, QuerySchema, Mappings, NewQueries) :-
    nl, write('For query schema '), write(QuerySchema),
    nl, write('Found schema mappings: '), nl, nl,
    write_separated_list(Mappings), nl,
    write_heading(['Repair the query according to the schema mappings']),
    repair_with_schema_maps(QueryTerm, Mappings, NewQueries),
    nl, nl, write('The query can be repaired in the following ways:'), nl,
    write_list(NewQueries, 20).

% make_target_candidates(+Datasets, +TargetSchemas, -Candidates)
% Get all the schemas whose functor matches our names (datasets) list
make_target_candidates(_Names, [], []) :- !.
make_target_candidates(Datasets, [Candidate |TargetSchemas], [Candidate|Candidates]) :-
    functor(Candidate, Name, _Arity),
    memberchk(Name, Datasets),  % Matching schema
    !,
    make_target_candidates(Datasets, TargetSchemas, Candidates).
make_target_candidates(Datasets, [_Candidate |TargetSchemas], Candidates) :-
    make_target_candidates(Datasets, TargetSchemas, Candidates).	
   

% Take the query and create a schema from it.
% i.e. make a query with no data values,
% just the tablename/rdf-filename and column-headings/rdf-predicate names.
% make_query_schema(+QueryTerm, -QuerySchema) :-
make_query_schema(QueryTerm, QuerySchema) :-
    ground(QueryTerm),
    !,
    QueryTerm =.. [Functor | QueryArgs],
    make_query_schema_args(QueryArgs, QSchemaArgs, Functor, NewFunctor),
    QuerySchema =.. [NewFunctor|QSchemaArgs].
make_query_schema(QueryTerm, _QuerySchema) :-
    \+ ground(QueryTerm),
    nl, write('The query '),
    writeq(QueryTerm),
    write(' contains a Prolog variable. All terms in the query that start with a capital letter must be enclosed in single quote marks.'),
    nl,
    append_to_output_nl(['The query ', QueryTerm, 'contains a Prolog variable.']),
    halt.

make_query_schema_args([], [], F, F) :- !.
make_query_schema_args([Arg|QueryArgs], QueryFunctors, _Functor, NewFunctor) :-
    Arg =..[type, TypeFunctor],
    !,
    make_query_schema_args(QueryArgs, QueryFunctors, TypeFunctor, NewFunctor).
make_query_schema_args([Arg|QueryArgs], [Functor|QueryFunctors], OldF, NewF) :-
    functor(Arg, Functor, _),
    make_query_schema_args(QueryArgs, QueryFunctors, OldF, NewF).


% For SAQ
load_local_prefixes :-
    environment_variable('DAISY_PREFIXES', FilePath),
%     write('Prefix Path: '), write(FilePath), nl,
    reconsult_local(FilePath).

load_target_schemas :-
    environment_variable('DAISY_TARGET_SCHEMAS', FilePath),
%    write('Target Path: '), write(FilePath), nl,
    reconsult_local(FilePath).

% make_target_names(+TargetSchemas, -SplitTargetNames).
make_target_names(TargetSchemas, SplitNames) :-
    runfiles_path('datasetNames.pl', DatasetNamesPath),
    open(DatasetNamesPath, write, DS),
    write_target_names(TargetSchemas, DS),
    close(DS),

    SplitDatasetNames = 'splitDatasetNames.pl',
    runfiles_path(SplitDatasetNames, SplitDatasetNamesPath),

    % Create the file of split dataset names.
    split_dataset_names(DatasetNamesPath, SplitDatasetNamesPath, 
			'Parsed names of target datasets:'),
    reconsult_runfile(SplitDatasetNames),
    setof(dataset(Name, Names),
	  utils:dataset(Name, Names),
	  SplitNames).

% Write the functor of each item in a list of terms to an
% open stream, each wrapped up in the form
% dataset('functor').
% write_target_names(+Terms, +Stream)
write_target_names([], _DS) :- !.
write_target_names([S|TargetSchemas], DS) :-
    functor(S, Name, _Arity),
    write(DS, 'dataset('), writeq(DS, Name), write(DS, ').'), nl(DS),
    write_target_names(TargetSchemas, DS).

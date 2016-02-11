% Run ./compareOAEI.sh and then one of the three predicates below.

:- module(compareOAEI, 
	  [compare_OAEI/0,
	   compare_OAEI/3,
	   compare_reference_OAEI/0
	 ]).

:- use_module(library(lists)).

:- use_module('../queryRespond/utils.pl').
:- use_module('../queryRespond/spsmMatch.pl').
:- use_module('../queryRespond/wordnetSearch.pl').
:- use_module('../queryRespond/sumoSearch.pl').
:- use_module('../queryRespond/narrowDatasets.pl').
:- use_module('../queryRespond/repair.pl').

conference_set(['cmt', 'Cocus', 'Conference', 'confious', 'confOf',
               'crs_dr', 'edas', 'ekaw', 'iasted',
%               'linklings',
               'MICRO', 'MyReview', 'OpenConf', 'paperdyne', 'PCS', 'sigkdd'
	      ]).

reference_set(['cmt', 'Conference', 'confOf',
                'edas', 'ekaw', 'iasted',
                'sigkdd'
 	      ]).

% Compare each file to all of the others.
% First treat  "Subject" as predicate, then "Property"
% Creates a huge great output/match_Subject.pl and output/match_Property.pl file
% for automated processing
% and a huge great output/result_Subject.txt and output/result_Property.txt file
% which are human readable.
% (nb This version does not match datasets against themselves)
compare_OAEI :-
    environment_variable('DAISY_OUTPUT', OutputPath),
    atoms_concat([OutputPath, '/matches_Subject.pl'], SubjectMatchesFile),
    open(SubjectMatchesFile, write, OP1),
    close(OP1),
    compare_OAEI('Subject'),
    atoms_concat([OutputPath, '/matches_Property.pl'], PropertyMatchesFile),
    open(PropertyMatchesFile, write, OP2),
    close(OP2),
    compare_OAEI('Property').

% Top-level call to compare only those datasets with reference alignments.
% This version
% creates the output in a series of separate files for each dataset pair,
% e.g. output/result_cmt_Conference_Subject.txt
%      output/result_cmt_iasted_Property.txt
% etc
% This version matches each dataset against itself as a check, e.g.
%      output/result_cmt_cmt_Subject.txt
% Results are also written to a Prolog format file, for automated analysis
%      output/matches_cmt_Conference_Subject.txt
compare_reference_OAEI :-
    reference_set(Sources),
    compare_reference_OAEI(Sources, 'Subject'),
    compare_reference_OAEI(Sources, 'Property').

compare_reference_OAEI([], _) :- !.
compare_reference_OAEI([Source|Sources], PropertyOrSubject) :-
    reference_set(Targets),
    compare_reference_OAEI(Source, Targets, PropertyOrSubject),
    !,
    compare_reference_OAEI(Sources, PropertyOrSubject).

compare_reference_OAEI(_Source, [], _PropertyOrSubject) :- !.
compare_reference_OAEI(Source, [Target|Targets], PropertyOrSubject) :-
    compare_OAEI(Source, Target, PropertyOrSubject),
    !,
    compare_reference_OAEI(Source, Targets, PropertyOrSubject).
    

% Test on a single Source and a single Target file, using either Subject
% or Property predicates.
% e.g. To compare cmt.owl with Conference.owl using Subject predicates:
%    compare_OAEI(cmt, 'Conference', 'Subject').
% Writes a file ../output/result_cmt_Conference_Subject.txt
%            (which is human-readable)
% and a file ../output/matches_cmt_Conference_Subject.txt
%            (which has a Prolog-y format for automated analysis later on.)
%
% This is the common call used by both compare_OAEI/0 (to compare
% all datasets) and compare_reference_OAEI/0.
%
compare_OAEI(Source, Target, PropertyOrSubject) :-
    new_output, 
    compare_OAEI_source_and_target(Source, Target, PropertyOrSubject, Matches),
    output_file(OutFile),
    environment_variable('DAISY_OUTPUT', OutputPath),
    atoms_concat([OutputPath, '/result_',Source,'_',Target,'_',PropertyOrSubject,'.txt'],
		 OutputFileFinal),
    system_instruction(['cp ', OutFile, ' ', OutputFileFinal]),
    atoms_concat([OutputPath, '/matches_', Source,'_',Target,'_',PropertyOrSubject,'.txt'],
		 OutputFileMatches),
    open(OutputFileMatches, write, OP),
    write(OP, 'matches('),
    writeq(OP,Source),
    write(OP, ', '),
    writeq(OP,Target),
    write(OP, ', '),
    writeq(OP, Matches),
    write(OP, ').'),
    nl(OP),
    close(OP).

compare_OAEI(PropertyOrSubject) :-
    conference_set(Sources),
    conference_set(Targets),
    new_output, 
    compare_OAEI_sources(Sources, Targets, PropertyOrSubject),
    output_file(OutFile),
    environment_variable('DAISY_OUTPUT', OutputPath),
    atoms_concat([OutputPath, '/result',PropertyOrSubject,'.txt'],
		 OutputFileFinal),
    system_instruction(['cp ', OutFile, ' ', OutputFileFinal]).

% e.g. compare_OAEI_sources([cmt, 'Conference', ekaw, ...],
%                           [cmt, 'Conference', ekaw, ...],
%                           'Subject')
compare_OAEI_sources([], _Targets, _PropertyOrSubject) :- !.
compare_OAEI_sources([Source|Sources], Targets, PropertyOrSubject) :-
    compare_OAEI_targets(Targets, Source, PropertyOrSubject),
    compare_OAEI_sources(Sources, Targets, PropertyOrSubject).

% e.g. compare_OAEI_targets(cmt
%                           [cmt, 'Conference', ekaw, ...],
%                           'Subject')
compare_OAEI_targets([], _Source, _PropertyOrSubject) :- !.
compare_OAEI_targets([Target|Targets], Source, PropertyOrSubject) :-
    Target \== Source,
    !,
    compare_OAEI_source_and_target(Source, Target, PropertyOrSubject, Matches),
    environment_variable('DAISY_OUTPUT', OutputPath),
    atoms_concat([OutputPath, '/matches_',PropertyOrSubject,'.pl'],
		 OutputFileMatches),
    open(OutputFileMatches, append, OP),
    write(OP, 'matches('),
    writeq(OP,Source),
    write(OP, ', '),
    writeq(OP,Target),
    write(OP, ', '),
    writeq(OP, Matches),
    write(OP, ').'),
    nl(OP),
    close(OP),
    compare_OAEI_targets(Targets, Source, PropertyOrSubject).
compare_OAEI_targets([_Target|Targets], Source, PropertyOrSubject) :-
    compare_OAEI_targets(Targets, Source, PropertyOrSubject).

compare_OAEI_source_and_target(Source, Target, PropertyOrSubject, Matches) :-
    append_to_output(['===================================================================']),
    append_to_output(['Source:', Source, '   Target:', Target,
			 '   ( predicate by', PropertyOrSubject, ')']),
    append_to_output(['===================================================================']),
    system_instruction(['python splitDatasetNames.py ', Source, ' query ',
			PropertyOrSubject]),
    system_instruction(['python splitDatasetNames.py ', Target, ' dataset ',
			PropertyOrSubject]),
    reconsult_runfile('splitQueryNames.pl'),
    reconsult_runfile('schemasQuery.pl'),
    reconsult_runfile('splitDatasetNames.pl'),
    reconsult_runfile('schemasDataset.pl'),
    write('Query Schemas:'), nl,
    setof(QSchema,
	  schemaQuery(QSchema),
	  QuerySchemas),
    write_list(QuerySchemas),
    append_result_to_output([Source, 'Query Schemas:'], QuerySchemas),
    nl,
    write('Query Predicate Names:'), nl,
    setof(query(QName, QNames),
	  query(QName, QNames),
	  SplitQueryNames),
    write_list(SplitQueryNames),
    append_result_to_output([Source, 'Query Predicate Names:'], SplitQueryNames),
    nl,
    write('Dataset Schemas:'), nl,
    setof(DSchema,
	  schemaDataset(DSchema),
	  DatasetSchemas),
    write_list(DatasetSchemas),
    append_result_to_output([Target, 'Dataset Schemas:'], DatasetSchemas),
    nl,
    write('Dataset Predicate Names:'), nl,
    setof(dataset(DName, DNames),
	  dataset(DName, DNames),
	  SplitDatasetNames),
    write_list(SplitDatasetNames),
    append_result_to_output([Target, 'Dataset Predicate Names:'], SplitDatasetNames),
    nl,
    process_OAEI(QuerySchemas, SplitQueryNames, DatasetSchemas, SplitDatasetNames, Matches).

% Recursive implementation to allow counting.
% Recurse through each query schema in turn, looking for target repairs.
% A useful predicate to spy while debugging because this predicate is
% called once for each query schema.
% spy(process_OAEI/5)
process_OAEI([], _SplitQueryNames, _DatasetSchemas, _SplitDatasetNames, []) :- !.
process_OAEI([SourceSchema|QuerySchemas], SplitQueryNames, DatasetSchemas, SplitDatasetNames, [M|MatchData]) :-
    nl, write_heading(['Query Schema: ', SourceSchema]),
    % append_to_output_nl([Source, 'Query Schema: ', SourceSchema]),

    SourceSchema =.. [SourcePredicate|_Rest],
    % There should only be one way to split the SourcePredicate
    member(query(SourcePredicate, SourceNames), SplitQueryNames),

    write_heading(['Expand the query schema']),
    nl, write('Expand the query dataset term using Wordnet search on'), nl,
    write(SourceNames), nl,
    connect_list_to_words(SourceNames, WordnetAssociatedTerms),
    nl, write('WordNet expanded the query dataset \''), write(SourcePredicate), write('\' to '), nl, write(WordnetAssociatedTerms), nl,
    nl, write('Expand the query dataset term using Sumo search'), nl,
    sumo_connection(SourceNames, SumoRelatedWordSets),
    nl, write('Sumo expanded the query dataset \''), write(SourcePredicate), write('\' to '), nl, write(SumoRelatedWordSets), nl,
    % Now get all the dataset names.
    nl, write('Narrowing the target datasets to choose ones related to query'), nl,
    narrow_datasets(SplitDatasetNames, WordnetAssociatedTerms, SumoRelatedWordSets, Datasets),
    nl, write('Narrowed to these target datasets: '), write(Datasets), nl,
    make_target_candidates(Datasets, DatasetSchemas, Candidates),
    nl, write('Schemas for the selected (narrowed) datasets are: '), nl,
    write_separated_list(Candidates), nl,
    write_heading(['Use SPSM to match the query and selected target schemas']),
    rank_matches(SourceSchema, Candidates, Maps), %SPSM
    write_separated_list(Maps), nl,
    write_heading(['Create repaired schemas']),
    repair_with_schema_maps(SourceSchema, Maps, NewQueries),
    append_result_to_output(['*** Repaired schemas:'], NewQueries),
    write_separated_list(NewQueries), nl,
    % Got some matches for this schema, now move on to the next.
    !,
    M = match(SourceSchema, Candidates, Maps, NewQueries),
    process_OAEI(QuerySchemas, SplitQueryNames, DatasetSchemas, SplitDatasetNames, MatchData).
% The match failed somewhere, so move on to the next schema.
process_OAEI([_SourceSchema|QuerySchemas], SplitQueryNames, DatasetSchemas, SplitDatasetNames, MatchData) :-
    process_OAEI(QuerySchemas, SplitQueryNames, DatasetSchemas, SplitDatasetNames, MatchData).


append_result_to_output(_Heading, []) :- !.
append_result_to_output(Heading, List) :-
    append_to_output(Heading),
    append_list_to_output(List).
			    

% The module system requires this.
dataset(Name, Names) :- utils:dataset(Name, Names).
query(Name, Names) :- utils:query(Name, Names).
schemaQuery(Schema) :- utils:schemaQuery(Schema).
schemaDataset(Schema) :- utils:schemaDataset(Schema).


make_target_candidates(DatasetNames, DatasetSchemas, Schemas) :-
    setof(DSchema,
	  Rest^Predicate^(member(DSchema, DatasetSchemas),
			  member(Predicate, DatasetNames),
			  DSchema =.. [Predicate|Rest]),
	  Schemas),
    !.
make_target_candidates(_DatasetNames, _DatasetSchemas, []).
	  

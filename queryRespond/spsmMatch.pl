:- module(spsmMatch, [rank_matches/3]).

:- use_module('utils.pl').

% rank_matches(+SourceSchema, +TargetSchemas, -MatchStructure)
% Use spsm to match the Source schema to each of the Target schemas in
% turn.
% Not all matches are successful. A list of successful matches is created.
% Each match is scored and the list of successful matches is sorted in
% score order (best first).
rank_matches(Source,Target_list, MatchStructure) :-
%Demo    nl, write('Source schema (Query): '), write(Source), nl,
%Demo    write('Target schema(s): '), nl, write_separated_list(Target_list), nl,
    find_match_list(Target_list, Source, Unranked_matches),
    nl, write('Filtering, sorting and formatting the results.'), nl,
%    nl, write('Trace 1 Unranked_matches '), nl, write(Unranked_matches), nl,
    order_list(Unranked_matches,Matches),
%    nl, write('Trace 2 (Ordered) Matches '), nl, write(Matches), nl,
    filter_empty_matches(Matches, NonEmptyMatches),
%    nl, write('Non-empty matches (best first): '), nl, write(NonEmptyMatches), nl,
    make_match_structure(NonEmptyMatches, MatchStructure).
%    nl, write('Trace 4 MatchStructure '), nl, write(MatchStructure), nl.

% Create a list of scored matches. The matches are represented
% by a list and the score is the first element of each list, to enable
% sorting.
find_match_list([], _Source, []).
find_match_list([First_target|Rest], Source, [Match_output|Matches]) :-
    find_match(Source, First_target, Match_output),
    find_match_list(Rest, Source, Matches).

% Each result.pl file that gets created seems to consist of:
% similarity(Number)
% match(none).
% and sometimes that's all, but sometimes there are more terms of the form:
% match[[queryword], operator, [targetword]])
% match[[queryword1, queryword2], operator, [targetword1, targetword2]])
% The first word of querywords is always the query dataset;
% if there is a second word it's a query column.
% The first word of targetwords is always the target dataset;
% if there is a second word it's a target column.
% I don't know if there can ever be more than two words!
% The operator is one of > = <
%
% For example:
%
% similarity(0.1428571428571429).
% match(none).
% match([[water],=,[waterBodyMeasures]]).
% match([[water,resource],>,[waterBodyMeasures,dataSource]]).
% match([[water,measure],=,[waterBodyMeasures,measureFixedDate]]).
% match([[water,measure],=,[waterBodyMeasures,measureId]]).
% match([[water,timePeriod],<,[waterBodyMeasures,waterBodyId]]]).

% Each time find_match is called it returns a structure made from these
% pieces. Match_output 
% Match_output = [0.0, [none]]
% Match_output = [0.142857,
%                 [none,
%                  [[water], =, [waterBodyMeasures]], 
%                  [[water, resource], >, [waterBodyMeasures, dataSource]],
%                  [[water, measure], =, [waterBodyMeasures, measureFixedDate]],
%                  [[water, measure], =, [waterBodyMeasures, measureId]],
%                  [[water, timePeriod], <, [waterBodyMeasures, waterBodyId]]
%                ]]

find_match(Source,Target,Match_output) :-
    wait_for_user,
    write_input_files(Source,Target),
    convert_to_path('/spsm/prolog-spsm.sh', Exec),
    nl,
    system_instruction([Exec]),    % This creates the file result.txt, the result of one match
    convert_to_path('/spsm/spsm-match-data/result.txt', ResultFile),
    nl, write('Created result.txt which contains match data:'),nl,
    system_instruction(silent, ['cat ', ResultFile]),
    append_to_output(['Created match data:']),
    append_file_to_output(ResultFile),
    interpret_match(Match_output).
%    nl, write('Trace find_match returns Match_output = '),
%    write(Match_output), nl.

write_input_files(Source,Target) :-
    % write('Trace: write_input_files '), nl,
    nl, write('Matching query schema source.txt '), write(Source), nl,
    append_to_output(['Matching query schema', Source]),
    write('to dataset schema target.txt '), write(Target), nl, nl,
    append_to_output(['to dataset schema', Target]),
    convert_to_path('/spsm/spsm-match-data/source.txt', SourceTextPath),
    open(SourceTextPath, write, SourceText),
    write(SourceText, Source),
    close(SourceText),
    convert_to_path('/spsm/spsm-match-data/target.txt', TargetTextPath),
    open(TargetTextPath, write, TargetText),
    write(TargetText, Target),
    close(TargetText).

% interpret_match(-ScoredMatch)
%
% Obtain the result of one match from result.pl with its score and entries
interpret_match([Score|[Matched_terms]]) :-
    % For some reason the spsm result.txt file can sometimes contain
    % extra or unbalanced query brackets.
    % This Python script sorts out the brackets (in a rather hacky way)
    % and wraps atoms in quotes to keep Prolog happy.
    % It creates a file called result.pl in the process
    % which is in proper loadable Prolog syntax.
    convert_to_path('/spsm/spsm-match-data/result.txt', ResultFile),
    convert_to_path('/spsm/spsm-match-data/result.pl', FixedFile),
    convert_to_path('/queryRespond/tidySPSM.py', TidySPSMProgram),

%    system_instruction(['sed \'s/]]])./]])./g\' ', ResultFile, ' > ', FixedFile]),
    % system_instruction(['python ', TidySPSMProgram, ' ', ResultFile, ' ', FixedFile]),
    system_instruction(silent, ['python ', TidySPSMProgram, ' ', ResultFile, ' ', FixedFile]),    
    reconsult(FixedFile),
    similarity(Score),
    findall(Match_info, match(Match_info), Matched_terms).

% Remove empty matches from the list of matches.
filter_empty_matches([], []) :- !.
filter_empty_matches([[_Score, [none]]|Rest], Filtered) :-
    !,
    filter_empty_matches(Rest, Filtered).
filter_empty_matches([NonEmpty|Rest], [NonEmpty|Filtered]) :-
    filter_empty_matches(Rest, Filtered).    


% Sort the list of scored matches by the score, highest first.
order_list(List,Sorted):-
    quick_sort(List,[],Sorted).

% quick_sort(+List, +Acc, -Result)
quick_sort([],Acc,Acc).
quick_sort([H|T],Acc,Sorted):-
    pivoting(H,T,L1,L2),
    quick_sort(L1,Acc,Sorted1),
    quick_sort(L2,[H|Sorted1],Sorted).

pivoting(_H,[],[],[]).
pivoting([H_score|H_matches],
	 [[First_score|First_matches]|T],
	 [[First_score|First_matches]|L],
	 G):-
    First_score=<H_score,
    pivoting([H_score|H_matches],T,L,G).
pivoting([H_score|H_matches],
	 [[First_score|First_matches]|T],
	 L,
	 [[First_score|First_matches]|G]):-
    First_score > H_score,
    pivoting([H_score|H_matches],T,L,G).

% Create a simpler data structure to hold the sorted match results.
make_match_structurea([], _) :-
    !,
    write('SPSM did not match any of the predicate names'),nl,
    append_to_output_nl(['SPSM did not match any of the predicate names']),    
    halt.
make_match_structure(Matches, StructuredMatches) :-
    make_match_structure_sub(Matches, StructuredMatches).

make_match_structure_sub([], []) :- !.
make_match_structure_sub([[Score, H]|T], [mapschema(score(Score), Match)|StructuredMatches]) :-
    make_one_match(H, Match),
    make_match_structure_sub(T, StructuredMatches).

% Remove the initial "none" entry from the match.
% Remove the Relation as we don't use it.
% Simplify the structure as much as possible.
% The expected input structire is something like this:
% [none, 
%    [[[n1],      =, [n2]], 
%     [[n1, nc1_1], =, [n2, nc2_1]],
%     [[n1, nc1_2], =, [n2, nc2_2]],
%     [[n1, nc1_3], =, [n2, nc2_3]],
% ....
% ]
% Where n1 and n2 are the dataset names (source and target respectively);
% and nc1_* are the source column names while nc2_* are the target column names.
% Return entries of the form
% [dataset(n1, n2),
%  column(nc1_1, nc2_1),
%  column(nc1_2, nc2_2),
%  column(nc1_3, nc2_3),
% ...]
% It is possible to have repeated entries, where the same source column can
% be represented by different target columns.
%  column(nc1_1, nc2_1),
%  column(nc1_1, nc2_2),...
% I'm not sure if other repetitions are possible. I think only one dataset
% mapping is possible at this level, so I only expect one dataset(_,_) pair.
% I am not sure whether two source columns could map onto the same
% target column. 
make_one_match([], []) :- !.
% Skip 'none'
make_one_match([none|Rest], Matches) :- !, make_one_match(Rest, Matches).
% A singleton list is the dataset name
% Sometimes the TargetDataset has extra parameters - this may be a bug.
make_one_match([[[SourceDataset], _Relation, [TargetDataset|_Params]]|Rest],
	       [dataset(SourceDataset, TargetDataset)|Matches]) :-
    !,
    make_one_match(Rest, Matches).
% A pair is the dataset and column name.
% Ignore the dataset names, we know what they are; just get the column names
make_one_match([[[_SourceDataset,SourceColumn], _Relation,
		 [_TargetDataset,TargetColumn]]|Rest],
	       [column(SourceColumn, TargetColumn)|Matches]) :-
    !,
    make_one_match(Rest, Matches).
% A triple is the dataset and column name, and the datatype of the column.
% Ignore the dataset names, we know what they are; ignore the
% column data types for the time being because I don't know
% what to do with them yet; just get the column names.
% Skip these 3-level matches since they always return a two-level match anyway.
make_one_match([[[_SourceDataset,_SourceColumn,_SourceDataType], _Relation,
		 [_TargetDataset,_TargetColumn,_TargetDataType]]|Rest],
	       Matches) :-
    !,
    make_one_match(Rest, Matches).
make_one_match([Entry|_Rest], _Matches) :-
    !, 
    write('Error: make_one_match/2 '), nl,
    write('SPSM has returned: '), writeq(Entry), nl,
    write('I have no idea how to parse it.'), nl,
    append_to_output_nl(['Error: make_one_match/2 ']),
    append_to_output_nl(['SPSM has returned: ', Entry]),
    append_to_output_nl(['I have no idea how to parse it.']),
    halt.




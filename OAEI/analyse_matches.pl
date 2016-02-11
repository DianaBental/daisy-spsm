%:- ['output/matches_Property.pl'].
%:- ['output/matches_Subject.pl'].

:- ['output/matches_all_Subject.pl'].
% :- ['output/matches_all_Property.pl'].

% File format: terms of the form
% matches(source, target, Matches)
%   There is one matches/3 term per {source, target} pair
% Matches is a list of terms of the form
%   match(SourceSchema, CandidateTargetSchemas, SPSMMatches, RepairedSchemas)
%   There is one list element per SourceSchema.
% CandidateTargetSchemas are the result of WordNet and Sumo expansion
% on the Predicate of the SoourceSchema, which is used to narrow the Target
% schemas.
% If CandidateTargetSchemas is [] then so is SPSMMatches and RepairedSchemas.
% SPSMMatches lists the schema matches.
%   mapschema(score(Score), [dataset(SourceAtom, TargetAtom),
%                            column(SourceAtom, TargetAtom),
%                            ...
%                            column(SourceAtom, TargetAtom)]
% Repaired Schemas lists the query schemas that could be made on the target.
% Some of the repaired schmeas consist only of the Predicate name.
% We could cosider this a meaningless match especially where the
% Predicate consists of an rdf property - a property with no values is
% meaningless. But it might count of the Predicate soncists of the subject
% of a triple, implying a possible match between the Subject values.

% Count how many schemas create a repaired predicate
match_table(Table) :-
    setof(t(source(Source), target(Target), count_repaired_schemas(Count)),
	  match_table(Source, Target, Count),
	  Table),
    sort(Table, SortedTable),
    write_table(SortedTable).

write_table([]) :- !.
write_table([t(S, T, C) | Table]) :-
    write(S), write(' '), write(T), write(' '), write(C), nl,
    write_table(Table).

% For each Source and Target file, count how many Source predicates have
% (one or more) repairs.
match_table(Source, Target, Count) :-
    matches(Source, Target, Matches),
    count_matches(Matches, 0, Count).

count_matches([], Count, Count) :- !.
count_matches([Match|Ms], CIn, Count) :-
    increment_match(Match, CIn, C),
    count_matches(Ms, C, Count).

% Add 1 if there are any repaired schemas at all for this schema.
% (If there are multiple repairs for the same schema then all the repairs will
%  still only count as one.)
increment_match(match(_Schema, _Candidates, _Maps, []), Count, Count) :- !.
increment_match(match(_Schema, _Candidates, _Maps, [_|_RepairedSchemas]),
	      CIn, Count) :- 
    Count is CIn + 1.


%%
repairs_table(Table) :-
    setof(t(source(Source), target(Target), count_repairs(Count)),
	  match_repairs(Source, Target, Count),
	  Table),
    sort(Table, SortedTable),
    write_table(SortedTable).

% For each Source and Target file, count how many repairs in total.
% Count each repair for the same schema separately.
match_repairs(Source, Target, Count) :-
    matches(Source, Target, Matches),
    count_repairs(Matches, 0, Count).

count_repairs([], Count, Count) :- !.
count_repairs([match(_Schema, _Candidates, _Maps, Repairs)|Ms], CIn, Count) :-
    increment_repairs(Repairs, CIn, C),
    count_repairs(Ms, C, Count).

% Add the number of there are any repaired schemas at all for this schema.
increment_repairs([], Count, Count) :- !.
increment_repairs([_|T], CIn, COut) :-
    Count is CIn+1,
    increment_repairs(T, Count, COut).

%%%%%%%
% This doesn't count anything! 
count :-
    matches(Source, Target, Matches),
    write(Source), nl,
    write(Target), nl,
    count(Matches).

count(Source, Target) :-
    matches(Source, Target, Matches),
    count(Matches).

count([]).
count([match(_Source, _, _, [])|Matches]) :-
    !,
    count(Matches).
count([match(Source, Candidates, Maps, NewQueries)|Matches]) :-
    !,
    write(Source), write(' '), write(NewQueries), nl,
    write('  '), write(Candidates), nl,
    write('  '), write(Maps), nl,
    count(Matches).
%%%%%%%

% For each pair of source and target:
% How big is the biggest repaired predicate?
% The "size" of the repair is the predicate (i.e. 1) plus the number of params
% So a repair person(email) would have size 2.
biggest(S) :-
    setof(t(source(Source), target(Target), biggest(Size)),
	  biggest(Source, Target, Size),
	  S),
    write_table(S).


biggest(Source, Target, Size) :-
    matches(Source, Target, Matches),
    biggest_repair(Matches, 0, Size).

% Given all the matches for one pair of Source and Target,
% find the size of the biggest repair.
%
% biggest(+SchemaMatches, +BiggestSizeSoFar, -BiggestSize)
%
% Last schema - return the size.
biggest_repair([], Size, Size) :- !.
% No matches for this schema - move on to the next.
biggest_repair([match(_Schema, _Candidates, _Maps, [])|Matches], SIn, Size) :-
    !,
    biggest_repair(Matches, SIn, Size).
% There are some matches for this schema - find the biggest so far
% and then move on to the next.
biggest_repair([match(_Schema, _Candidates, _Maps, [Repaired|Reps])|Matches],
	SIn, SOut) :-
    !,
    biggest_term_in_list([Repaired|Reps], SIn, Size),
    biggest_repair(Matches, Size, SOut).


biggest_term_in_list([], Size, Size) :- !.
biggest_term_in_list([H|T], SIn, SOut) :-
    functor(H, _F, Arity),
    NewSize is Arity+1,
    max(NewSize, SIn, Size),
    biggest_term_in_list(T, Size, SOut).


max(A, B, A) :- A>B, !.
max(_A, B, B).

:- dynamic match_size/2.

match_size(0, 0).
match_size(1, 0).
match_size(2, 0).
match_size(3, 0).
match_size(4, 0).
match_size(5, 0).
match_size(6, 0).
match_size(7, 0).
match_size(8, 0).
match_size(9, 0).
match_size(10, 0).
match_size(11, 0).
match_size(12, 0).
match_size(13, 0).
match_size(14, 0).
match_size(15, 0).
match_size(16, 0).
match_size(17, 0).
match_size(18, 0).
match_size(19, 0).
match_size(20, 0).

:- dynamic source_predicate_size/2.


source_predicate_size(0, 0).
source_predicate_size(1, 0).
source_predicate_size(2, 0).
source_predicate_size(3, 0).
source_predicate_size(4, 0).
source_predicate_size(5, 0).
source_predicate_size(6, 0).
source_predicate_size(7, 0).
source_predicate_size(8, 0).
source_predicate_size(9, 0).
source_predicate_size(10, 0).
source_predicate_size(11, 0).
source_predicate_size(12, 0).
source_predicate_size(13, 0).
source_predicate_size(14, 0).
source_predicate_size(15, 0).
source_predicate_size(16, 0).
source_predicate_size(17, 0).
source_predicate_size(18, 0).
source_predicate_size(19, 0).
source_predicate_size(20, 0).

%% How many predicates of each size in each (source) file?
% predicate_sizes(S).
% listing(source_predicate_sizes)
predicate_sizes(Sources) :-
    setof(Source,
	  Target^Matches^matches(Source, Target, Matches),
	  Sources),
    predicate_sizes_sub(Sources).

predicate_sizes_sub([]) :- !.
predicate_sizes_sub([Source|Sources]) :-
    matches(Source, _Target, Matches),
    !, % Just the one....
    count_predicate_sizes(Matches),
    predicate_sizes_sub(Sources).


count_predicate_sizes([]) :- !.
count_predicate_sizes([match(SourcePred, _CandidateTargets, _MatchInfo, _Repairs)|Rest]) :-
    SourcePred =.. L, length(L, SourceLength),
    retract(source_predicate_size(SourceLength, Count)),
    C1 is Count + 1,
    assert(source_predicate_size(SourceLength, C1)),
    !,
    count_predicate_sizes(Rest).

%%
% How many matches (repairs) of each size?
% Multiple repairs for the same schema will each be counted individually.
%% match_sizes(T).
%% listing(match_size).
match_sizes(T) :-
    setof(matches(Source, Target, Matches),
	  matches(Source, Target, Matches),
	  Matches),
    count_sizes(Matches).

count_sizes([]) :- !.
count_sizes([matches(_Source, _Target, MatchPreds)|Rest]) :-
    count_entries(MatchPreds),
    count_sizes(Rest).

count_entries([]) :- !.
count_entries([match(_SourcePred, _CandidateTargets, _MatchInfo, Repairs)|Rest]) :-
    count_repair_lengths(Repairs),
    count_entries(Rest).

count_repair_lengths([]) :-!.
count_repair_lengths([Repair|R]) :-
    Repair =.. L, length(L, RepairLength),
    retract(match_size(RepairLength, Count)),
    C1 is Count + 1,
    assert(match_size(RepairLength, C1)),
    count_repair_lengths(R).

% count_predicates(cmt, C).
% Counts all the predicates in  dataset.
count_predicates(Dataset, Count) :-
    matches(Dataset, _Target, Matches),
    !,
    count_predicates_sub(Matches, Count).

count_predicates_sub([], 0) :- !.
count_predicates_sub([match(_, _, _,_)|T], Count) :-
    count_predicates_sub(T, C1),
    Count is C1 + 1.

% count_unique_columns(cmt, C)
% Lists all the column names in a dataset and counts them.
count_unique_columns(Dataset, Count) :-
    matches(Dataset, _Target, Matches),
    !,
    count_unique_columns_sub(Matches, Count).

count_unique_columns_sub(Matches, Count) :-
    setof(Arg,
	  Schema^C^MI^R^Functor^Args^(member(match(Schema, C, MI, R), Matches),
	     Schema =.. [Functor|Args],
	     member(Arg, Args)),
	  Columns),
    write(Columns),
    length(Columns, Count).

			 



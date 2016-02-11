:- module(sumoSearch, [sumo_connection/2]).

:- use_module(utils).
:- use_module(library(lists)).

% Reads a large database of sumo relations (into the utils module)
:- consult_local('sumo/sumo.pl').

% nb the need to refer to utils explicitly is a side effect of
% the module system; consult_local loads things into utils since that
% is where consult_local is defined. 

% Take a word set (e.g. the result of splitting a dataset name into separate
% words) and find all the word sets related to it through Sumo.
% sumo_connection(+Words, -ListOfWordSets)
sumo_connection(WordSet, RelatedWordSets) :-
    setof(RelatedWordSet,
	  sumo_connect(WordSet, RelatedWordSet),
	  RelatedWordSets),
    !.
sumo_connection(_WordSet, []).  % There are no Sumo related wordsets.

% A set of words (WordSet) connects with another set via sumo
% if the WordSet is a subset of the words in a sumo relation
% and then we return the set of words on the other side of the relation.
% sumo_connect(+WordSet, -RelatedWordSet)
sumo_connect(WordSet, RelatedWordSet ) :-
    sumo_relation(SumoWordSet, RelatedWordSet),
    is_subset(WordSet, SumoWordSet).

% sumo_relation(+Words, -Words)
sumo_relation(S1, S2) :- utils:subclassOf(S1, S2).
sumo_relation(S1, S2) :- utils:subclassOf(S2, S1).
sumo_relation(S1, S2) :- utils:instanceOf(S1, S2).
sumo_relation(S1, S2) :- utils:instanceOf(S2, S1).
sumo_relation(S1, S2) :- utils:overlapsspatially(S1, S2).
sumo_relation(S1, S2) :- utils:overlapsspatially(S2, S1).
sumo_relation(S1, S2) :- utils:geographicsubregion(S1, S2).
sumo_relation(S1, S2) :- utils:geographicsubregion(S2, S1).


:- module(narrowDatasets, [narrow_datasets/4]).

% :- use_module(library(system3)). % SICSTUS
:- use_module(library(lists)).

:- use_module('utils.pl').

% Use the results of Wordnet (and Sumo) on the query dataset (predicate) name
% to restrict the potential target dataset names for matching.

% WordNet and Sumo query expansions return differently structured results
% so we do the matching differently for each one.
%
% narrow_datasets(+NamesData, +WordNetQueryConnections, +SumoQueryConnections,
%                 -TargetDataSets)
%
% NamesData is a list of pairs of the form
% [dataset(TargetDatasetNameOne, [Target, Dataset, Name, One],
%  dataset(AnotherDatasetName, [Another, Dataset, Name], ....]
narrow_datasets(NamesData, WordNetQueryConnections, SumoQueryConnections, TargetDataSets) :-
    narrow_datasets_wordnet(NamesData, WordNetQueryConnections, WordnetDataSets), 
    narrow_datasets_sumo(NamesData, SumoQueryConnections, SumoDataSets),
    make_union(WordnetDataSets, SumoDataSets, TargetDataSets).

% narrow_datasets_wordnet(+NamesData, +WordNetQueryConnections, -TargetDataSets)
%
% WordNetQueryConnections are a set of pairs of the form
% [connected(Name, ListofAssociatedNames), ....]
% e.g [connected(water, ['H2O', backwater, 'bath water', bay, bilge, ...]
% (At the moment I still don't do anything to deal with multiword
% atoms from WordNet.)
narrow_datasets_wordnet(NamesData, WordNetQueryConnections, TargetDataSets) :-
    setof(TargetDataSet,
	  wn_matches_dataset(NamesData, TargetDataSet, WordNetQueryConnections),
	  TargetDataSets),
    !.
narrow_datasets_wordnet(_NamesData, _WordNetQueryConnections, []).

% WordNet: Decide that a target dataset matches the query dataset
% either if any one of the words in the target dataset name is the same
% as a word in the query dataset name ; 
% or if any of the words in the target dataset
% name is the same as the one the words related to a word in the query.
% (I could do something more complicated like counting the matches and
% sorting the results but I don't)
wn_matches_dataset(NamesData, TargetDataSet, WordNetQueryConnections) :-
    % Find a target dataset and its component words
    member(dataset(TargetDataSet, SplitNames),  NamesData),
    member(NameWord, SplitNames),  % Check each word at a time
    member(connected(Word, Words), WordNetQueryConnections),
    wn_matches(NameWord, Word, Words).
%%    write(TargetDataSet), write(' '), write(NameWord), write(' '), nl.

% wn_matches(+Name1, +Name2, +AssociatedNames)
wn_matches(NameWord, NameWord, _) :- !. % A word from the query is the same as
                                     % a word from a target dataset.
wn_matches(NameWord, _, Words) :-   % A word frome the query is the same as
    member(NameWord, Words),     % one of the associated words in the 
    !.                           % target dataset.


% narrow_datasets_sumo(+NamesData, +SumoTermSets, -DatasetNames)
%
% Sumo: We have a list of sets of Sumo terms. If any of these sets match a set
% of dataset words, then that dataset is added to the narrowed datasets.
% Matching consists of a simple subset - i.e. if all the sumo terms that
% correspond to the query term are also in the dataset name, then the dataset
% matches the query.
%
% SumoTermSets just looks like a single nested list, in which each sublist
% contains one or more atoms, i.e. words which make up a phrase.
% e.g. [[artifact], [body, of, water], [channel], [cloud], [collection] ....]
narrow_datasets_sumo(NamesData, SumoTermSets, Names) :-
    setof(Name,
	  sumo_matches(NamesData, SumoTermSets, Name),
	  Names),
     !.
narrow_datasets_sumo(_NamesData, _SumoTermSets, []). % No additional matches

% sumo_matches(+NamesData, +SumoTermSets, -DatasetName)
sumo_matches(NamesData, SumoTermSets, DatasetName) :-
    member(dataset(DatasetName, SplitNames), NamesData),
    member(SumoTermSet, SumoTermSets),
    is_subset(SumoTermSet, SplitNames).

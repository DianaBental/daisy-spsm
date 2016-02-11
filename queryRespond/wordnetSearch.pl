:- module(wordnet, [connect_list_to_words/2]).

:- use_module(utils).

% Load the wordnet datasbases (into module utils)
:-
    consult_local('wordnet/wn_s.pl'), 
    consult_local('wordnet/wn_sim.pl'),
    consult_local('wordnet/wn_hyp.pl'),
    consult_local('wordnet/wn_ins.pl'),
    consult_local('wordnet/wn_mm.pl').

% nb the need to refer to utils explicitly is a side effect of
% the module system; consult_local loads things into utils since that
% is where consult_local is defined. 

% Given a list of words, we return list of the words that associated
% with each one.

% Note that some of the returned "words" are really phrases separated
% by spaces. I should sort this out but at the the moment I have just returned
% each one literally as an atom. It could be sorted out by returning
% sets of words,
% which is what the sumo expander will need to do. So I will sort out sumo
% first and then maybe come back to this.

% connect_list_to_words(+Words, -LinkedWords)
% Given a list of words(atoms), look for all the words associated with
% each word in the list and return a structure of each word paired with
% the wordnet-associated words
%
% e.g. A call connect_list_to_words([water, body, measures], LinkedWords).
% returns a structure
% [connected(body, ['Christendom', administration, anatomy, .....]),
%  connected(measures, []),
%  connected(water, [[H2O, backwater, bath water, bay, bilge, ....])]
%
% Note that 'measures' has no Wordnet connections (though the singular
% 'measure' does) and so it returns an empty list.
connect_list_to_words(WordsInName, LinkedWords) :-
    setof(connected(W, Connections),
	   (member(W, WordsInName),
	    connections(W, Connections)),
	   LinkedWords).

% Connect a single word to a list of Wordnet words.
% connections(+Word1, -Connections)
connections(Word1, Connections) :-
    setof(Word2, connects(Word1, Word2), Connections),
    !.
connections(_Word1, []). % Return an empty set if there are no connections.

% connects(+Word1, -Word2)
% Wordnet connects Word1 to Word2 in some way.
connects(Word1, Word2) :-
    eithercase(Word1, Word1UpperOrLower),
    connects(Word1UpperOrLower, Word2, _How).

% connects(+Word1, -Word2, -How)
% The third parameter 'How' isn't really important and could be removed - it's
% mostly there for debugging, so I can inspect which relations are matching
% (if I want to.)
% Other terms for the same synset (not in the original)
connects(Word1, Word2, synset) :-
    utils:s(Synset, Num1, Word1, PartofSpeech, _A1, _B1),
    utils:s(Synset, Num2, Word2, PartofSpeech, _A2, _B2),
    Num1 =\= Num2.
% Terms related by similarity, hyper/hyponym (broader/narrower),
% sub/superclass, meronym (part/whole) 
% Take a single step along each relation.  
connects(Word1, Word2, How) :-
    utils:s(Synset1, _N1, Word1, _PoS1, _A1, _B1),
    relation(Synset1, Synset2, How),
    utils:s(Synset2, _N2, Word2, _PoS2, _A2, _B2).

% sim is similarity (it contains links both ways)
relation(Synset1, Synset2, sim) :- utils:sim(Synset1,Synset2).
% hyp is hypernym / hyponym (i.e. broader/narrower, depending which way round)
relation(Synset1, Synset2, hyp1) :- utils:hyp(Synset1,Synset2).
relation(Synset1, Synset2, hyp2) :- utils:hyp(Synset2,Synset1).
% ins is SubClass and SuperClass
relation(Synset1, Synset2, ins1) :- utils:ins(Synset1,Synset2).
relation(Synset1, Synset2, ins2) :- utils:ins(Synset2,Synset1).
% Meronyms (part-whole) - the original only does meroynms one way
relation(Synset1, Synset2, mm1) :- utils:mm(Synset1,Synset2).
relation(Synset1, Synset2, mm2) :- utils:mm(Synset2,Synset1). % not in the original


eithercase(Atom, Either) :- upcase(Atom, Either).
eithercase(Atom, Either) :- downcase(Atom, Either).


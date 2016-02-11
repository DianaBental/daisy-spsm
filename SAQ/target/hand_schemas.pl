% Schema Query 1
target(entity(type('Astronaut'), nationality)).

% Schema Query 2
target(entity(type('Town'), country, populationTotal, leader)).
target(entity(type('City'), country, populationTotal)).

% Schema Query 4
target(entity(type('Mountain'), elevation)).

% Schema Query 5, 6, 12, 17, 19, 21, 25
target(entity(type('Person'), occupation, birthPlace, birthName, deathPlace, instrument, spouse, battle)).

% Schema Query 8
target(entity(type('FormulaOneRacer'), races)).

% Schema Query 10
target(entity(type('River'), length)).

% Schema Query 11
target(entity(type('Automobile'), assembly)).

% Schema Query 14
target(entity(type('StatesOfTheUnitedStates'), admittancedate)).

% Schema Query 16
target(entity(type('Film'), director)).

% Schema Query 18
target(entity(type('Politician'), religion)).

% Schema Query 20
target(entity(type('Nonprofit_organization'),locationCountry)).

% Schema Query 23
target(entity(type('Company'), location, headquarter, locationCity)).

% Schema Query 28
target(entity(type('Island'), country)).

% No type information
% Schema Query 3, 15, 22, 24, 27, 29, 30
target(entity(leader,
	      language, populationTotal, publisher, occupation, birthPlace,
	      leaderParty, mission)).



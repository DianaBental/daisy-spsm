:- module(repair, [repair_with_schema_maps/3,
		   repair_data/2]).

:- use_module('utils.pl').

% repair_with_schema_maps(+QueryTerm, +QuerySchema, +Mappings, -NewQueries)
%
% Each mapschema represents a single dataset.
% Within each dataset there may be several possible combinations of columns,
% because one query column has more than potential target match.
%
% Use setof to generate every possible combination of query columns.
% Only generate the largest possible sets of columns.
%
% e.g. 
% QueryTerm = water(subject('10065'), resource, measure, geo, timePeriod)
% QuerySchema = water(resource, measure, geo, timePeriod)
% Mappings = [mapschema(score(0.142857), 
%                       [dataset(water, waterBodyMeasures), 
%                        column(resource, dataSource), 
%                        column(measure, measureFixedDate),
%                        column(measure, measureId), 
%                        column(timePeriod, waterBodyId)]), 
%             mapschema(score(0.0714286), 
%                       [dataset(water, waterBodyPressures), 
%                        column(resource, dataSource), 
%                        column(measure, assessmentCategory), 
%                        column(geo, affectsGroundwater), 
%                        column(timePeriod, identifiedDate)])]
% Then:
% NewQueries = [
% waterBodyMeasures(subject(10065), dataSource, measureFixedDate, waterBodyId),
% waterBodyMeasures(subject(10065), dataSource, measureId, waterBodyId),
% waterBodyPressures(subject(10065), dataSource, assessmentCategory, 
%                    affectsGroundwater, identifiedDate)
% ]
% Note that waterBodyMeasures makes two queries, for the different mappings
% of 'measure'.
% This is brute force generation.
% Since the mappings have already been sorted into order by their SPSM
% score, in effect this returns the best matches at the start of the set.

repair_with_schema_maps(QueryTerm, Mappings, NewQueries) :-
    QueryTerm =.. [Source | Params],
    % Use setof to generate all the query mappings at once.
    setof(NewQuery,
	  repair_with_schema_maps_sub(Source, Params, Mappings, NewQuery),
	  NewQueries),
    !.
repair_with_schema_maps(_QueryTerm, _Mappings, []).

% repair_with_schema_maps_sub(+Source, +Params, +Mappings, -NewQuery)
% e.g. Source = water  (i.e. query dataset)
% Params = [resource, measure, geo, timePeriod]  (i.e. query columns)
% Mappings = mapschema(score(0.142857), 
%                       [dataset(water, waterBodyMeasures), 
%                        column(resource, dataSource), 
%                        column(measure, measureFixedDate),
%                        column(measure, measureId), 
%                        column(timePeriod, waterBodyId)])
repair_with_schema_maps_sub(Source, Params, Mappings, NewQuery) :-
    % Use member to walk through the mapschemas
    member(mapschema(_Score, Map), Mappings),
    % Use member to pick out the Source dataset name (only necessary
    % because of the way the mapschemas are structured as a list)
    member(dataset(Source, Target), Map),
    % Map the query parameters (column names) onto the target names
    % There may be more than one mapping for column names, so map_params
    % may succeed more than once for a single dataset.
    map_params(Params, Map, Result),
    NewQuery =.. [Target|Result].
%    nl, write('New query: '),
%    write(NewQuery).

% Map the query column names onto target column names.
% Transfer the subject "as is".
% Ignore query columns with no matching target - leave them out of the
% target query.
% If any columns have alternative target matches, failure will return
% different combinations.
map_params([], _, []) :- !.
% Deal with the rdf-subject (and include its value if it has one).
% nb the example query has a subject value and will return subject('10065')
map_params([Subject|Params], Mappings, [Subject|Result]) :-
    Subject =.. [subject|_Value],
    !,
    map_params(Params, Mappings, Result).
% Deal with a column that doesn't have a target column - leave it out.
map_params([Source|Params], Mappings, Result) :-
    Source =.. [SourceColumn|_Value],
    \+ member(column(SourceColumn, _TargetColumn), Mappings),
    !,
    map_params(Params, Mappings, Result).
% Deal with a column that has one or more target columns (and include
% its value if it has one - NB the example query shown above only has column 
% names and not values.)
% If there is more than one target column, they will be returned one at a
% time on failure (and picked up by setof)
% e.g. for Source=measure
% Mappings contains
%      column(measure, measureFixedDate),
%      column(measure, measureId), ...
% so there will be (at least) two different sets of Results, one using
% measureFixedDate and one using MeasureId.
map_params([Source|Params], Mappings, [Target|Result]) :-
    Source =.. [SourceColumn|Value],
    member(column(SourceColumn, TargetColumn), Mappings),
    Target =.. [TargetColumn|Value],
    map_params(Params, Mappings, Result).


% repair_data(+Query, -NewQuery)
%
% The only data repair we do is to uninstantiate the columns, one at a time;
% And then uninstantiate all columns.
repair_data(Query, NewQuery) :-
    Query =.. [Dataset|Params],
    uninstantiate_a_param(Params, NewParams, true),
    NewQuery =.. [Dataset|NewParams].
repair_data(Query, NewQuery) :-
    Query =.. [Dataset|Params],
    uninstantiate_all_params(Params, NewParams, N),
    N > 1,
    write('Data repair: uninstantiated all parameters'), nl,
    NewQuery =.. [Dataset|NewParams].

uninstantiate_a_param([], [], false) :- !.
uninstantiate_a_param([Param|Params], [Column|Params], true) :-
    Param =.. [Column, _Value],
    write('Data repair: uninstantiate '), write(Column), nl.
uninstantiate_a_param([Param|Params], [Param|NewParams], Changed) :-
    uninstantiate_a_param(Params, NewParams, Changed).

% Uninstantiate all params in the query. Count the params that get
% uninstantiated - this enables us to check that there is more than 1.
% We have already queried with 0 and 1 params uninstantiated, so there will
% be no point querying again unless there are 2 or more params with values.
uninstantiate_all_params(Params, NewParams, N) :-
    uninstantiate_all_params(Params, NewParams, 0, N).

uninstantiate_all_params([], [], N, N) :- !.
uninstantiate_all_params([Param|Params], [Column|NewParams], NIn, NOut) :-
    Param =.. [Column, _Value],
    !,
    N is NIn + 1,
    uninstantiate_all_params(Params, NewParams, N, NOut).
uninstantiate_all_params([Param|Params], [Param|NewParams], NIn, NOut) :-
    uninstantiate_all_params(Params, NewParams, NIn, NOut).

    


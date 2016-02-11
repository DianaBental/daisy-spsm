% This module is probably misnamed. What it does now, is to formulate a
% candidate Sparql query and run it on the target dataset.
%
% This is the query that should actually return some data. It can be
% called multiple times, using different versions of the query schema and
% different datasets.
%
% Files created
% Each time start_translation is called, it creates either 1 or 3 files:
% - it always writes the Sparql query to a file called Query.sparql;
% - if the query completes then the results (whch may be empty) are written
%   to a file called QueryResults.txt (table format) or
%   QueryResults.csv (csv format);
% - and a file called queryMatches.pl
%   is written to hold a flag about whether the query returned any
%   results or not.
%  (If the query does not complete then QueryResults.txt/csv is left in its old
%  state)

:- module(translation, [start_translation/3]).

% :-use_module(library(system3)). % SICSTUS
:-use_module(library(lists)).

:- use_module('utils.pl').

% Settings to create either a csv file or a table for ARQ.
%
% sparql_output_mode(+mode, -FileName, -EmptyLines, -Size)
% For a csv file: if there is only one line then there were no matches (the first line
% is just the variables)
% For a Table file: if there are four lines then there were no 
% matches (the first five lines are just the header)
sparql_output_mode(csv, 'QueryResults.csv', ' --results csv > ', 1).
sparql_output_mode(table, 'QueryResults.txt', ' > ', 4).

% Settings to create a python dictionary as outputs from CSV datasets.
% (This format is quite similar to JSON...)
csv_output_mode(python_dictionary, 'QueryResults.py', 0).

% start_translation(+TargetFilesType, +Query, -Success)
start_translation(TargetFilesType, Query, Success) :-
    nl, write('Construct query for '), writeq(Query), nl,
    append_to_output(['Construct query', Query]),
    construct_query(TargetFilesType, Query, Dataset),
    wait_for_user,
    perform_query(TargetFilesType, Dataset, Success).

% construct_query(+FileType, +Query, -Dataset)
construct_query(csv, Query, Dataset) :-
    Query =.. [Dataset | Columns],
    % CSV files are interpreteted using a Python script
    % So we need to format the query as Python (using a Python dictionary)
    % e.g. Prolog query: 
    %      people(height, age(21), id, name)
    % becomes in Python:
    %      {'height': None, 'age': '21', 'id': None, 'name': None}
    open_runtime_file('Query.py', write, IQ),
    write(IQ, '{'),
    create_python_dictionary(Columns, IQ),
    write(IQ, '}'),
    nl(IQ),
    close(IQ),
    % Display the query
    runfiles_path('Query.py', QPath),
    system_instruction(silent, ['cat ', QPath]).

create_python_dictionary([], _IQ) :- !.
% We have a list of columns which are either just column names whose values
% we want to return, or else pairs of column and value
create_python_dictionary([Column], QF) :-
    !,
    create_one_python_entry(Column, QF).
create_python_dictionary([Column|Columns], QF) :-
    !,
    create_one_python_entry(Column, QF),
    write(QF, ', '),
    create_python_dictionary(Columns, QF).

create_one_python_entry(Column, QF) :-
    functor(Column, Functor, 0),  % it is a just a column name (no data)
    !,
    write(QF, '\''), write(QF, Functor), write(QF, '\': None').
create_one_python_entry(Column, QF) :-
    functor(Column, Functor, 1),  % there is a data value
    Column =.. [Functor, Value],
    !,
    write(QF, '\''), write(QF, Functor), write(QF, '\': '),
    write(QF, '\''), write(QF, Value), write(QF, '\'').
% We are only expecting either columnName or columnName(value)
% so anything bigger, like columName(v1, v2) is an error.
create_one_python_entry(Column, _QF) :-
    write('**create_one_python_entry/2 bad column parameter in schmema'),
    write(Column),
    nl,
    halt.

construct_query(n3, Query, Dataset) :-
%     Query =.. [Dataset, Subject | Columns],
    Query =.. [Dataset | Params],
    extract_subject(Params, Subject, Columns),
    open_runtime_file('Query.sparql', write, IQ),
    create_SPARQL_select_statement(Subject, Columns, IQ),
    create_SPARQL_from_statement(Dataset, IQ),
    create_SPARQL_where_statement(Subject, Columns, IQ),
    close(IQ),
    % Display the query
    runfiles_path('Query.sparql', QPath),
    system_instruction(silent, ['cat ', QPath]).


extract_subject([], subject, []) :- !. % No subject specified - so get an empty subject
extract_subject([Subject|Columns], Subject, Columns) :-
    is_subject(Subject),
    !.
extract_subject([Column|Params], Subject, [Column|Columns]) :-
    !,
    extract_subject(Params, Subject, Columns).

is_subject(subject) :- !.
is_subject(subject(_Value)).


% Write the SELECT ?variable1 ?variable2 ... part of the query
% This comes in two parts; the RDF subject, if there is one, and
% then the list of RDF objects (or columns)
% create_SPARQL_select_statement(+Subject, +Columns, +QF)
create_SPARQL_select_statement(Subject, Columns, QF) :-
    write(QF, 'SELECT'),
    create_SPARQL_select_subject(Subject, QF),
    create_SPARQL_select_list(Columns, QF),
    nl(QF).

%  RDF triples are always of the form Subject Predicate Object
%  and the "Subject" isn't part of an SQL database
%  so we have to do something special about it.
%  The first argument in our query is either 'subject' (in which case
%  it's an unbound variable and we're going to return its value)
%  or else it's subject('somevalue') in which case we're not going to
%  return the value (but we're going to match on it in the WHERE part later on)
create_SPARQL_select_subject(subject(_Value), _QF) :- !.
create_SPARQL_select_subject(subject, QF) :-
    !,
    write(QF, ' ?subject').
create_SPARQL_select_subject(Subject, _QF) :-
    write('**create_SPARQL_select_subject/2 bad subject paramter'),
    write(Subject),
    nl,
    halt.

% We have a list of columns which are either just column names whose values
% we want to return, or else pairs of column and value (in the form
% columnName(value) in which case we don't want to return anything (but
% we will match on it in the WHERE part later on)
create_SPARQL_select_list([], _QF) :- !.
create_SPARQL_select_list([Column|Columns], QF) :-
    functor(Column, Functor, 0),  % it is a just a column name (no data)
    !,
    write(QF, ' ?'), write(QF, Functor),  % so create a variable
    create_SPARQL_select_list(Columns, QF).
create_SPARQL_select_list([Column|Columns], QF) :-
    functor(Column, _Functor, 1),  % there is a data value so skip the variable
    !,
    create_SPARQL_select_list(Columns, QF).
% We are only expecting either columnName or columName(value)
% so anything bigger, like columName(v1, v2) is an error.
create_SPARQL_select_list([Column|_Columns], _QF) :-
    write('**create_SPARQL_select_list/2 bad column parameter in schema'),
    write(Column),
    nl,
    halt.

% Write the FROM part of a sparql query
% FROM <directory/file.n3>
% Yes, for the time being we're assuming it comes from a local n3 file
% (And the filename corresponds to the first functor in the query term,
% also to an SQL table name if we were doing SQL.)
create_SPARQL_from_statement(FileName, QF) :-
    % SPARQL should look for the table in an .n3 file in the data directory
    environment_variable('DAISY_TARGET_DATA', DataDirectoryPath),
    write(QF, ' FROM <'),
    write(QF, DataDirectoryPath), 
    write(QF, '/'), 
    write(QF, FileName),
    write(QF, '.n3>'),
    nl(QF).

% WHERE { ?subject <column1> ?column1 ;
%                  <column2> value2 ;
%       .... etc
%}
create_SPARQL_where_statement(Subject, Columns, QF) :-
    write(QF, 'WHERE { '),
    create_SPARQL_where_subject(Subject, QF),
    create_SPARQL_where_columns(Columns, QF),
    write(QF, ' . }'),
    nl(QF),
    !.

% If the subject is an open variable ...
create_SPARQL_where_subject(subject, QF) :-
    !,
    write(QF, '?subject ').
% Or if we've given the subject a value, then match on the value.
create_SPARQL_where_subject(subject(Value), QF) :-
    !,
    write_SPARQL_subject(QF, Value),
    write(QF, ' ').
create_SPARQL_where_subject(Subject, _QF) :-
    write('**create_SPARQL_where_subject/2 bad subject parameter '),
    write(Subject),
    nl,
    halt.

% Write an RDF subject into a SPARQL query for matching
% Might be a variable or a URI
write_SPARQL_subject(_QF, Value):-
    \+ground(Value),
    !,
    write('**write_SPARQL_subject ERROR term must not contain Prolog variables'), nl,
    halt.
write_SPARQL_subject(QF, Value):-
    atom(Value),
    \+ integer(Value),
    name(Value, [60|_Rest]), % It starts with < so we assume it's a URI
    !,
    write(QF, Value).  % and write it out plain
write_SPARQL_subject(QF, Value) :-
    write(QF, '<'),  % Assume it's a URI and put angle brackets round it
    write(QF, Value),
    write(QF, '>').
    
% Write an RDF value into a SPARQL query for matching
% Might be a URI, or an integer, or a literal string.
% We don't allow prefixes in the value (object) part of a query.
write_SPARQL_value(_QF, Value) :-
    \+ground(Value),
    !,
    write('**write_SPARQL_value ERROR term must not contain Prolog variables'), nl,
    halt.
write_SPARQL_value(QF, Value) :-
    integer(Value),  % An integer - write it out plain.
    !,
    write(QF, Value).
write_SPARQL_value(QF, Value) :-
    atom(Value),
    \+ integer(Value),
    name(Value, [60|_Rest]), % It starts with < so we assume it's a URI
    !,
    write(QF, Value).  % and write it out plain
write_SPARQL_value(QF, Value) :-
    atom(Value),  % Any other atom
    !,
    write(QF, '"'),  % Assume it's a literal and put quotes round it.
    write(QF, Value),
    write(QF, '"').
write_SPARQL_value(_QF, Value) :-
    write('**write_SPARQL_value ERROR unregnised SPARQL value in query:'), 
    write(Value), nl,
    halt.

    
    

% Write the columns and variables or values, separated with colons
% Pick off the first column and deal with it
create_SPARQL_where_columns([First|Rest], QF) :-
    !,
    create_SPARQL_where_column_sub(First, QF),
    create_SPARQL_where_columns_rest(Rest, QF).
create_SPARQL_where_columns([], _QF) :-
    !,
    write('**create_SPARQL_where_columns/2 No columns in schema'),
    nl,
    halt.
create_SPARQL_where_columns(_Columns, _QF) :-
    write('**create_SPARQL_where_columns/2 Bad columns in schema'),
    nl,
    halt.

% Colon-separate the rest of the columns, recursively.
create_SPARQL_where_columns_rest([], _QF) :- ! .
create_SPARQL_where_columns_rest([Column|Columns], QF) :-
    write(QF, ' ; '),
    nl(QF),
    create_SPARQL_where_column_sub(Column, QF),
    create_SPARQL_where_columns_rest(Columns, QF).

% Print either
% column ?column
% or
% column value
create_SPARQL_where_column_sub(Column, QF) :-
    functor(Column, Functor, 0),  % it is a just a column name (no data)
    !,
    write_prefixed_predicate(Functor, QF),
    write(QF, ' ?'), write(QF, Functor).  % and match the variable
create_SPARQL_where_column_sub(Column, QF) :-
    functor(Column, Functor, 1),  % there is a data value 
    !,
    write_prefixed_predicate(Functor, QF),
    write(QF, ' '),
    arg(1, Column, Value),
    write_SPARQL_value(QF, Value).
% We are only expecting either columnName or columName(value)
% so anything bigger, like columnName(v1, v2) is an error.
create_SPARQL_where_column_sub(Column, _QF) :-
    write('**create_SPARQL_where_column_sub/2 bad column parameter '),
    write(Column),
    nl,
    halt.

% Find the prefix associated with the rdf-predicate and write prefixed
% rdf-predicate into the SPARQL.
%
% Initially the rdf-predicate may come from the source; later it may be
% from a target file. Depending entirely on which prefixes_*.pl files
% has most recently been loaded.
%
% The associatedPrefix terms get loaded into the utils
%  module because that's
% the way modules work. An alternative strategy, of putting them into
% a specially named module, failed, because that somehow stopped Prolog
% from over-writing the previous prefixes.
write_prefixed_predicate(Ending, QF) :-
    (utils:associatedPrefix(Ending, Prefix),
     atom_concat(Prefix, Ending, Predicate)
     ;
     Predicate = Ending
     ),
    % write the column (rdf predicate) name
    write(QF, '<'), write(QF, Predicate),  write(QF, '>'),
    !.

% perform_query(+Type, +Dataset, -Result)
% 
% Execute a sparql query from the file we created previously and
% store the result (if there is one).
%
% Type is only sparql at present.
% Result is success, no_data or failure.
% Success means some data was found.
% Failure either means the query was buggy or else that the dataset names
% did not match. In this case schema repair is appropriate.
% No_data means that the query schema was valid but returned no data - 
% might be asking for inappropriate/non-existent data values, or
% for data across a non-existent combination of columns. In this case
% data repair is appropriate.
%
% nb the Dataset is already built in to the SPARQL query so we don't
% use it explicitly here.
perform_query(n3, _Dataset, Result) :-
    runfiles_path('Query.sparql', SparqlQuery),
%     sparql_output_mode(table, FileName, SparqlDirection, Size), %% csv output
    sparql_output_mode(table, FileName, SparqlDirection, Size),  %% tabular output
    runfiles_path(FileName, SparqlQueryResults),
    atoms_concat(['arq', 
		  ' --query ', SparqlQuery,
		  SparqlDirection, SparqlQueryResults], Query),  %% Table format
    system_instruction([Query]),   % This call may fail if the the query is inappropriate,
    % especially if the dataset name is not matched. If it fails,
    % no QueryResults.csv/txt file is created.
    %
    % If the previous system call succeeded, then look for matching data.
    !,
    executed_query(SparqlQueryResults, Size, Result).
    %% (look_for_matches(SparqlQueryResults, Size, yes),
    %%  !,
    %%  Result = success,
    %%  write('The query succeeded. The returned answers are:'), nl,
    %%  system_instruction(silent, ['head -n100 ', SparqlQueryResults]),
    %%  nl,
    %%  append_to_output(['The query succeeded. The returned answers are:']),
    %%  append_file_to_output(SparqlQueryResults)
    %% ;
    %% Result = no_data,
    %% write('The query did not return any data.'), nl,
    %% append_to_output_nl(['The query did not return any data.'])
    %% ).
perform_query(n3, _Dataset, failure) :-
    write('The query failed.'), nl,
    append_to_output_nl(['The query failed.']).

perform_query(csv, Dataset, Result) :-
    % The dataset file
    target_data_path(Dataset, DataPath), % in the target directory ..
    atom_concat(DataPath, '.csv', DatasetPath), % look for a .csv file
    % The query we just made
    runfiles_path('Query.py', PyCSVQuery),
    % set the output file name and the size (of an empty result file)
    csv_output_mode(python_dictionary, OutfileName, Size),
    % The file and directory for the output file
    runfiles_path(OutfileName, QueryResults),
    % The file and directory for the Python code
    environment_variable('DAISY_HOME', DaisyHome),
    atom_concat(DaisyHome, '/queryRespond/csvQuery.py', Python),

    system_instruction(['python ', Python, ' ', DatasetPath, ' ',
		  PyCSVQuery, ' ', QueryResults]),
    !,
    executed_query(QueryResults, Size, Result).
    %% (look_for_matches(QueryResults, Size, yes),
    %%  !,
    %%  Result = success,
    %%  write('The query succeeded. The returned answers are:'), nl,
    %%  system_instruction(silent, ['head -n100 ', QueryResults]),
    %%  nl,
    %%  append_to_output(['The query succeeded. The returned answers are:']),
    %%  append_file_to_output(QueryResults)
    %% ;
    %% Result = no_data,
    %% write('The query did not return any data.'), nl,
    %% append_to_output_nl(['The query did not return any data.'])
    %% ).
perform_query(csv, _Dataset, failure) :-
    write('The query failed.'), nl,
    append_to_output_nl(['The query failed.']).

executed_query(QueryResults, Size, success) :-
    look_for_matches(QueryResults, Size, yes),
    !,
    write('The query succeeded. The returned answers are:'), nl,
    system_instruction(silent, ['head -n100 ', QueryResults]),
    nl,
    append_to_output(['The query succeeded. The returned answers are:']),
    append_file_to_output(QueryResults).
executed_query(_QueryResults, _Size, no_data) :-
    write('The query did not return any data.'), nl,
    append_to_output_nl(['The query did not return any data.']).


look_for_matches(QueryResults, Size, Matches) :-
    % Run a shell script which counts the lines in the query result file;
    % If there are more lines than just the heading then there
    % were data matches.
    % Creates a temporary file to hold the flag and reads it back in.
    %
    % Create the script
    runfiles_path('query_matches.pl', MatchFlagFile),
    atoms_concat(['if [ `cat ', QueryResults, ' | wc -l` -gt "',
		  Size, '" ] ; ',
		  'then echo "query_matches(yes)." > ', MatchFlagFile, '; ',
		  'else echo "query_matches(no)." > ', MatchFlagFile, '; ',
		  'fi'],
		 ShellScript),
    % Execute it
    system_instruction(silent, [ShellScript]),
    % Read the result back in.
    reconsult(MatchFlagFile),
    % Return the result
    query_matches(Matches).

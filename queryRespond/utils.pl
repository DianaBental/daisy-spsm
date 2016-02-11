:- module(utils,
	  [
	   open_runtime_file/3,
	   runfiles_path/2,
	   reconsult_runfile/1,
	   reconsult_local/1,

	   open_local/3,
	   convert_to_path/2,
	   consult_local/1,
	   query_path/2,
	   source_data_path/2,
	   target_data_path/2,

	   new_output/0,
	   output_file/1,
	   append_to_output/1,
	   append_to_output_nl/1,
	   append_file_to_output/1,
	   append_list_to_output/1,

	   atoms_concat/2,
	   write_list/1,
	   write_list/2,	   
	   write_separated_list/1,
	   write_heading/1,

	   upcase/2,
	   downcase/2,

	   wait_for_user/0,
	   
	   % Wrappers for system calls for SICSTUS/SWI Prolog
	   % compatibility.
	   system_instruction/1,
	   system_instruction/2,
	   environment_variable/2,
	   get_directory_files/2,
	   is_subset/2,
	   make_union/3]).

:- dynamic associatedPrefix/2.

% :- use_module(library(system3)). % SICSTUS
% :- use_module(library(sets)).    %SICSTUS

:- use_module(library(lists)).

% Open a file (or path) relative to $DAISY_RUN and return the stream
% Used for files that the system creates at runtime, to put themin a common
% directory.
% Modes are read/write/append
% open_runtime_file(+File, +Mode, -Stream) :-
% e.g. open_runtime_file('file.txt', read, Stream)
%  opens a file /home/dsb5/CHAIN/code/daisy-spsm/file.txt for reading
open_runtime_file(File, Mode, Stream) :-
    runfiles_path(File, FilePath),
    open(FilePath, Mode, Stream).

reconsult_runfile(File) :-
    runfiles_path(File, FilePath),
    reconsult(FilePath).

% Reconsult a file into the utils module
reconsult_local(File) :-
    reconsult(File).
    

% Open a file (or path) relative to $DAISY_HOME and return the stream
% Modes are read/write/append
% open_local(+File, +Mode, -Stream) :-
% e.g. open_loca('file.txt', read, Stream)
%  opens a file /home/dsb5/CHAIN/code/daisy-spsm/file.txt for reading
open_local(File, Mode, Stream) :-
    environment_variable('DAISY_HOME', Env),
    atoms_concat([Env, '/', File], FullPath),
    open(FullPath, Mode, Stream).

% Convert a directory or filename to a full pathname extended by $DAISY_HOME
% (Note the input name needs to start with /
% convert_to_path(+File, -Path)
convert_to_path(File, Path) :-
	environment_variable('DAISY_HOME', Env),
	atom_concat(Env, File, Path).

% Consult a file relative to the path
% consult_local(+File)
consult_local(File) :-
	environment_variable('DAISY_HOME', Env),
	atoms_concat([Env, '/queryRespond/', File], Path),
	consult(Path).

% Extend a filename to the query directory
% query_path(+File, -FilePath)
query_path(File, FilePath) :-
    environment_variable('DAISY_QUERY', QueryPath),
    atom_concat(QueryPath, '/', QPath),
    atom_concat(QPath, File, FilePath),
    write('Query Path: '), write(FilePath), nl.

% Extend a filename to the source data directory
% source_data_path(+File, -FilePath)
source_data_path(File, FilePath) :-
    environment_variable('DAISY_SOURCE_DATA', QueryPath),
    atom_concat(QueryPath, '/', QPath),
    atom_concat(QPath, File, FilePath).
%Demo    write('Source Data Path: '), write(FilePath), nl.

% Extend a filename to the target data directory
% target_data_path(+File, -FilePath)
target_data_path(File, FilePath) :-
    environment_variable('DAISY_TARGET_DATA', QueryPath),
    atom_concat(QueryPath, '/', QPath),
    atom_concat(QPath, File, FilePath).
%    write('Target Data Path: '), write(FilePath), nl.

% Extend a filename to the runfile (temp files) data directory
% runfiles_path(+File, -FilePath)
runfiles_path(File, FilePath) :-
    environment_variable('DAISY_RUNFILES', RunFilesPath),
    atom_concat(RunFilesPath, '/', RPath),
    atom_concat(RPath, File, FilePath).

% Some predicates to manage the output "result.txt" file.
% This is a single fixed file for storing results.
% These could be parameterised to handle multiple output files, but
% they aren't.
%
% Get the path of output file
% output_file(-OutFile)
output_file(OutFile) :-
    environment_variable('DAISY_OUTPUT', OutputPath),
    atom_concat(OutputPath, '/result.txt', OutFile).
%
% Empty the output file if it exists; create it, if not.
new_output :-
    output_file(OutFile),
    open(OutFile, write, OP),
    close(OP).
%
% Write one line to the the output file. The line is a list of terms, each
% term is separated, by spaces and ends with a newline.
% append_to_output(+ListOfTerms)
append_to_output(ListOfTerms) :-
    output_file(OutFile),
    open(OutFile, append, OP),
    append_to_output_sub(ListOfTerms, OP),
    nl(OP),
    close(OP).

%
% Write one line to the the output file followed by a blank line.
% The line is  a list of terms, each term is separated, by spaces.
% append_to_output_nl(+ListOfTerms)
append_to_output_nl(ListOfTerms) :-
    output_file(OutFile),
    open(OutFile, append, OP),
    append_to_output_sub(ListOfTerms, OP),
    nl(OP), nl(OP),
    close(OP).

% Write a list of terms, separated by spaces, to an open FileHandle
% append_to_output_sub(+ListOfTerms, +FileHandle)
append_to_output_sub([], _) :- !.
append_to_output_sub([H|T], OP) :-
    write(OP, H),
    write(OP, ' '),
    append_to_output_sub(T, OP).

% Copy a whole file (well, the first 100 lines of the file anyway)
% onto the end of the output file; followed by one blank line.
% append_file_to_output(+FilePath)
append_file_to_output(FilePath) :-
    output_file(OutFile),
    system_instruction(silent, ['head -n100 ', FilePath, ' >> ', OutFile]),
    append_to_output([]).  % blank line

%
% Write a list of lines to the the output file. Each line is a terms, each
% term is separated by a newline.
% append_to_output(+ListOfTerms)
append_list_to_output(ListOfTerms) :-
    output_file(OutFile),
    open(OutFile, append, OP),
    append_list_to_output_sub(ListOfTerms, OP),
    nl(OP),
    close(OP).

append_list_to_output_sub([], _OP) :- !.
append_list_to_output_sub([H|T], OP) :-
    write(OP, H),
    nl(OP),
    append_list_to_output_sub(T, OP).

% Concatenate a list of atoms into a single atom (useful for building filepaths)
% atoms_concat(+Atoms, -LongAtom)
atoms_concat([], '') :- !.
atoms_concat([H|T], String) :-
    atoms_concat(T, End),
    atom_concat(H, End, String).

% Write a list of terms, separated by newlines
% write_list(+List)
write_list([]).
write_list([H|T]) :-
    write(H), nl, write_list(T).

% Write the first N in a list of terms, separated by newlines
% write_list(+List, +N)
write_list([], _) :- !.
write_list([_H|_], 0) :- !, write('....'), nl.
write_list([H|T], N) :-
    write(H), nl, N1 is N-1, write_list(T, N1).

% Write a list of terms, separated by a blank line.
% write_separated_list(+List)
write_separated_list([]).
write_separated_list([H|T]) :-
    write(H), nl, nl, write_separated_list(T).

% Write a heading - a list of terms, surrounded by a blank line and some
% asterisks.
% write_heading(+List)
write_heading(Terms) :-
    nl, nl, write('*****************************************************'), nl,
    write_heading_sub(Terms),
    write('*****************************************************'),
    nl, nl.

write_heading_sub([]).
write_heading_sub([H|T]) :-
    write(H), nl, write_heading_sub(T).

% system_instruction(+Instructions)
% system_instruction(report, +Instructions)
% system_instruction(silent, +Instructions)
% Build and perform a complex shell command.
%
% Instructions should be a list of atoms. They get joined to gether to form
% a one-line shell command, which is executed.
%
% This code does not insert spaces - the Instructions list must contain
% all the spaces it needs.
%
% system_instruction/1 and system_instruction(report, [...]) both
% write the shell command on screen before they execute it.
% system_instruction(silent, [...]) executes without showing the command.
%
% Use instead of SWI Prolog shell/1 or SICSTUS system/1. 
system_instruction(Instructions) :-
    system_instruction(report, Instructions).
    
system_instruction(Reporting, Instructions) :-
    is_list(Instructions),
    ground(Instructions),
    !,
    atoms_concat(Instructions, ShellCommand),
    system_instruction_sub(Reporting, ShellCommand).
system_instruction(_R, Instructions) :-
    write('Error: utils:system_instructions(..) requires a list of ground terms.'),
    nl, write(Instructions), nl,
    fail.


system_instruction_sub(report, ShellCommand) :-
    !,
    write(ShellCommand), nl,
    system(ShellCommand).
system_instruction_sub(silent, ShellCommand) :-
    !,
    system(ShellCommand).
system_instruction_sub(Nonsense, ShellCommand) :-
    write(Nonsense), write(' is not a valid option for system_instruction/2'),
    nl,
    write(ShellCommand), nl, fail.

% environment_variable(+ShellVariableAsAtom, -Value)
% Read a shell variable
% Sictsus/SWI Prolog compatibility - use instead of environ/1 or get_env/1 
environment_variable(Variable, Value) :-
    environ(Variable, Value).

% get_directory_files(+Directory, -Files)
% Get a list of a files in a directory.
% Compatibility wrapper for SICSTUS/SWI Prolog.
get_directory_files(Directory, Files) :-
    directory_files(Directory, Files).

% is_subset(+SubSet, +Set)
% Test if SubSet is a subset of Set (only tests, not generates)
is_subset(SubSet, Set) :-
    subset(SubSet, Set).

% make_union(+Set1, +Set2, -Union)
% Union is the union of Set1 and Set2
make_union(Set1, Set2, Union) :-
    union(Set1, Set2, Union).


% Convert the first letter of an atom (if it starts with a letter)
% to upper or lower case respectively.
upcase(Atom, UpCase) :- 
    atom_codes(Atom, [C|CAT]), to_upper(C, U), atom_codes(UpCase, [U|CAT]).
downcase(Atom, DownCase) :- 
    atom_codes(Atom, [C|CAT]), to_lower(C, L), atom_codes(DownCase, [L|CAT]).


% SICSTUS prolog definitions in SWI-Prolog
%
%%%% DELETE or COMMENT OUT FROM HERE FOR SICTSUS; INCLUDE FOR SWI PROLOG
%
% Read a shell variable
% environ(+ShellVariableAsAtom, -Value) :-
environ(Variable, Value) :-
    getenv(Variable, Value).

% Execute a system command
% system(+SystemCommandAsAtom)
system(Command) :-
    shell(Command).

% Make a list of all the files in a directory
% This shoukd exist in SWI Prolog but doesn't seem to - maybe an old vesion
directory_files(Directory, Files) :-
    % make up a pattern which matches all files in the directory
    atom_concat(Directory, '/*', DirectoryPattern),
    % look for all the files
    expand_file_name(DirectoryPattern, FilePaths),  
    % Strip off the paths so we just have a set of filenames
    setof(File, 
	  F^(member(F, FilePaths), file_base_name(F, File)), 
	  Files).

%%%% DELETE or COMMENT OUT TO HERE FOR SICTSUS


% Pront a prompt and wait for the user to hit carriage return
wait_for_user :-
    environment_variable('DAISY_RUN_TYPE', interactive),
    !,
    wait_for_user_sub.
wait_for_user.

wait_for_user_sub :-
    write('> '), flush_output,
    get_code(user_input, 98),
    prolog.
wait_for_user_sub.

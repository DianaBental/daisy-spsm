water(subject('10065'), resource, measure, geo(10075), timePeriod).
% Different versions of the query - for testing.
% These should give the same result as the above query
% water(resource, measure, geo, timePeriod, subject('10065')).
% water(subject(10065), resource, measure, geo, timePeriod).

% These should all work, with an uninstantiated subject.
% water(resource, measure, geo, timePeriod, subject).
% water(subject, resource, measure, geo, timePeriod).
% water(resource, measure, geo, timePeriod).

% These use ithe old query format, which will not cause a crash but wont
% behave in the old way, because single atoms (even numbers) are
% interpreted as column names not data values. The old format should be
% replaced by the one of the formats using "subject" at the top.
% This version maps the integer 10065 to a column name and matches on it.
% water(resource, measure, geo, timePeriod, 10065).
% This version ignores the number, because the atom '10065' 
% is translated to integer 10065 when values are returned
% from SPSM,  and Prolog does not recognise that the two are equal.
% water(resource, measure, geo, timePeriod, '10065').

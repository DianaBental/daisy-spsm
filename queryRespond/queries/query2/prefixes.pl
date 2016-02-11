:-dynamic sepaPrefix/2.
:-dynamic subject/1.
:-dynamic associatedPrefix/2.

sepaPrefix(geo, ' <http://www.w3.org/2003/01/ge0/wgs84_pos#>') .
sepaPrefix(sepaidw ,'<http://data.sepa.org.uk/id/Water/> ').
sepaPrefix(sepaidloc,'<http://data.sepa.org.uk/id/Location/>') .
sepaPrefix(rdf    ,'<http://www.w3.org/1999/02/22-rdf-syntax-ns#>') .
sepaPrefix(sepaw  ,'<http://data.sepa.org.uk/ont/Water#>') .
sepaPrefix(sepaloc, '<http://data.sepa.org.uk/ont/Location#>') .

%%% subject(+Subject).
subject('sepaidloc:202936').
associatedPrefix(sepaloc, catchment).
associatedPrefix(sepaloc ,localAuthority).





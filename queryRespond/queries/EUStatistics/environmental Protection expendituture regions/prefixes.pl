:-dynamic sepaPrefix/2.
:-dynamic subject/1.
:-dynamic associatedPrefix/2.

sepaPrefix(geo, ' <http://www.w3.org/2003/01/ge0/wgs84_pos#>') .
sepaPrefix(sepaidw ,'<http://data.sepa.org.uk/id/Water/> ').
sepaPrefix(sepaidloc,'<http://data.sepa.org.uk/id/Location/>') .
sepaPrefix(rdf    ,'<http://www.w3.org/1999/02/22-rdf-syntax-ns#>') .
sepaPrefix(sepaw  ,'<http://data.sepa.org.uk/ont/Water#>') .

%%% subject(+Subject).
subject('10065').





associatedPrefix(sepaw, dimension).
associatedPrefix(sepaw, unit).
associatedPrefix(sepaw,environmentDomain).
associatedPrefix(sepaw, environmentExposure).
associatedPrefix(sepaw,geo).



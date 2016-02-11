:-dynamic sepaPrefix/2.
:-dynamic subject/1.
:-dynamic associatedPrefix/2.

sepaPrefix(geo, ' <http://www.w3.org/2003/01/ge0/wgs84_pos#>') .
sepaPrefix(sepaidw ,'<http://data.sepa.org.uk/id/Water/> ').
sepaPrefix(sepaidloc,'<http://data.sepa.org.uk/id/Location/>') .
sepaPrefix(rdf    ,'<http://www.w3.org/1999/02/22-rdf-syntax-ns#>') .
sepaPrefix(sepaw  ,'<http://data.sepa.org.uk/ont/Water#>') .

%%% subject(+Subject).
subject('sepaidw:20399').


associatedPrefix(sepaw,atcoCode).	
associatedPrefix(sepaw,startDate).	
associatedPrefix(sepaw,endDate).	
associatedPrefix(sepaw,availabilityStatus).	
associatedPrefix(sepaw,note).	
associatedPrefix(sepaw,noteLang).
associatedPrefix(sepaw,transferStopAtcoCode).	
associatedPrefix(sepaw,creationDateTime	).
associatedPrefix(sepaw,modificationDateTime).
associatedPrefix(sepaw, revisionNumber).	
associatedPrefix(sepaw,modification).

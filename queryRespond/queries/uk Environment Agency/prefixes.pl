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



 associatedPrefix(sepaw,sampleClassification).
associatedPrefix(sepaw, prefLabel).
associatedPrefix(sepaw, long).
associatedPrefix(sepaw, lat).
associatedPrefix(sepaw,northing).
associatedPrefix(sepaw, easting).
associatedPrefix(sepaw,  latestComplianceAssessment).
associatedPrefix(sepaw, type).
associatedPrefix(sepaw, country).
associatedPrefix(sepaw, district).
associatedPrefix(sepaw, envelope).
associatedPrefix(sepaw, latestBathingWaterProfile).
associatedPrefix(sepaw, sedimentTypesPresent).
associatedPrefix(sepaw, uriSet).
associatedPrefix(sepaw, regionalOrganization).
associatedPrefix(sepaw, yearDesignated).
associatedPrefix(sepaw, latestSampleAssessment).
associatedPrefix(sepaw, eubWidNotation).
associatedPrefix(sepaw, waterQualityImpactedByHeavyRain).
associatedPrefix(sepaw, zoneOfInfluence).
associatedPrefix(sepaw, samplingPoint).
associatedPrefix(sepaw, complianceClassification).
associatedPrefix(sepaw, primaryTopic).
associatedPrefix(sepaw, extendedMetadataVersion).
associatedPrefix(sepaw, definition).
associatedPrefix(sepaw, label).



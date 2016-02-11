#!/bin/bash

#export DAISY_HOME_LOCAL=~/CHAIN/code/daisy-spsm
export DAISY_HOME_LOCAL=$DAISY_HOME
export SPSM_HOME=$DAISY_HOME_LOCAL/spsm
# export S_MATCH_HOME=$DAISY_HOME_LOCAL/spsm/s-match-20110317
export S_MATCH_HOME=$DAISY_HOME_LOCAL/spsm/s-match

pushd .
cd $S_MATCH_HOME/bin
#echo $S_MATCH_HOME
./prolog-spsm.sh $SPSM_HOME/spsm-match-data/source.txt $SPSM_HOME/spsm-match-data/target.txt $SPSM_HOME/spsm-match-data/result.txt > /dev/null


popd

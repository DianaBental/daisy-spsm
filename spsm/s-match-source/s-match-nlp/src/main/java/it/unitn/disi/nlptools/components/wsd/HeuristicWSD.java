package it.unitn.disi.nlptools.components.wsd;

import it.unitn.disi.nlptools.components.PipelineComponentException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;
import it.unitn.disi.smatch.data.ling.ISense;
import it.unitn.disi.smatch.oracles.ISenseMatcher;
import it.unitn.disi.smatch.oracles.SenseMatcherException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Disambiguates senses using simple heuristics.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class HeuristicWSD extends LabelPipelineComponent {

    private final ISenseMatcher senseMatcher;

    public HeuristicWSD(ISenseMatcher senseMatcher) {
        this.senseMatcher = senseMatcher;
    }

    public void process(ILabel instance) throws PipelineComponentException {
        HashMap<IToken, List<ISense>> refinedSenses = new HashMap<>();

        try {
            for (IToken sourceToken : instance.getTokens()) {
                for (IToken targetToken : instance.getTokens()) {
                    if (!targetToken.equals(sourceToken)) {
                        for (ISense sourceSense : sourceToken.getSenses()) {
                            for (ISense targetSense : targetToken.getSenses()) {
                                if (senseMatcher.isSourceSynonymTarget(sourceSense, targetSense) ||
                                        senseMatcher.isSourceLessGeneralThanTarget(sourceSense, targetSense) ||
                                        senseMatcher.isSourceMoreGeneralThanTarget(sourceSense, targetSense)) {
                                    addToRefinedSenses(refinedSenses, sourceToken, sourceSense);
                                    addToRefinedSenses(refinedSenses, targetToken, targetSense);
                                }
                            }
                        }
                    }
                }
            }

            //sense disambiguation in context
            for (IToken sourceToken : instance.getTokens()) {
                if (!refinedSenses.containsKey(sourceToken)) {
                    for (ISense sourceSense : sourceToken.getSenses()) {
                        // for all context labels
                        senseFilteringAmong(instance.getContext(), sourceSense, sourceToken, refinedSenses);
                    }
                }
            }

            //replace sense with refined ones, if there are any
            for (IToken token : instance.getTokens()) {
                List<ISense> refined = refinedSenses.get(token);
                if (null != refined) {
                    token.setSenses(refined);
                }
            }
        } catch (SenseMatcherException e) {
            throw new PipelineComponentException(e.getMessage(), e);
        }
    }

    private void senseFilteringAmong(List<ILabel> context, ISense sourceSense, IToken sourceToken, HashMap<IToken, List<ISense>> refinedSenses) throws SenseMatcherException {
        for (ILabel targetLabel : context) {
            for (IToken targetToken : targetLabel.getTokens()) {
                if (!refinedSenses.containsKey(targetToken)) {
                    for (ISense targetSense : targetToken.getSenses()) {
                        //check whether each sense not synonym or more general, less general then the senses of
                        //the ancestors and descendants of the node in context hierarchy
                        if ((senseMatcher.isSourceSynonymTarget(sourceSense, targetSense)) ||
                                (senseMatcher.isSourceLessGeneralThanTarget(sourceSense, targetSense)) ||
                                (senseMatcher.isSourceMoreGeneralThanTarget(sourceSense, targetSense))) {
                            addToRefinedSenses(refinedSenses, sourceToken, sourceSense);
                            addToRefinedSenses(refinedSenses, targetToken, targetSense);
                        }
                    }
                }
            }
        }
    }

    private void addToRefinedSenses(HashMap<IToken, List<ISense>> refinedSenses, IToken token, ISense sense) {
        List<ISense> senses = refinedSenses.get(token);
        if (null == senses) {
            senses = new ArrayList<>();
        }
        senses.add(sense);
        refinedSenses.put(token, senses);
    }
}
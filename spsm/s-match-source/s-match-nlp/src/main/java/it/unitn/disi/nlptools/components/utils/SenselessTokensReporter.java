package it.unitn.disi.nlptools.components.utils;

import it.unitn.disi.nlptools.components.PipelineComponentException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Reports senseless tokens.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class SenselessTokensReporter extends LabelPipelineComponent {

    private static final Logger log = LoggerFactory.getLogger(SenselessTokensReporter.class);

    public void process(ILabel instance) throws PipelineComponentException {
        for (IToken token : instance.getTokens()) {
            if (0 == token.getSenses().size()) {
                log.debug("Unrecognized word: " + token.getText());
            }
        }
    }
}
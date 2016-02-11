package it.unitn.disi.nlptools.components.utils;

import it.unitn.disi.nlptools.components.PipelineComponentException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Reports labels with empty formulas.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class EmptyFormulasReporter extends LabelPipelineComponent {

    private static final Logger log = LoggerFactory.getLogger(EmptyFormulasReporter.class);

    public void process(ILabel instance) throws PipelineComponentException {
        if (null == instance.getFormula() || instance.getFormula().isEmpty()) {
            log.debug("Empty formula for label: " + instance.getText());
        }
    }
}
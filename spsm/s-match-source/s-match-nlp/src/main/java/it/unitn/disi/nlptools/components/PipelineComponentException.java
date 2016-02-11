package it.unitn.disi.nlptools.components;

import it.unitn.disi.nlptools.NLPToolsException;

/**
 * Exception for pipeline components.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class PipelineComponentException extends NLPToolsException {

    public PipelineComponentException(String errorDescription) {
        super(errorDescription);
    }

    public PipelineComponentException(String errorDescription, Throwable cause) {
        super(errorDescription, cause);
    }
}

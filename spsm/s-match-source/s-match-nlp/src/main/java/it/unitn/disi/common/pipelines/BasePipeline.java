package it.unitn.disi.common.pipelines;

import it.unitn.disi.nlptools.components.PipelineComponentException;

import java.util.List;

/**
 * Base pipeline class.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class BasePipeline<E> implements IBasePipeline<E> {

    protected final List<IBasePipelineComponent<E>> pipelineComponents;

    public BasePipeline(List<IBasePipelineComponent<E>> pipelineComponents) {
        this.pipelineComponents = pipelineComponents;
    }

    public void process(E instance) throws PipelineComponentException {
        for (IBasePipelineComponent<E> c : pipelineComponents) {
            c.beforeInstanceProcessing(instance);
        }
        for (IBasePipelineComponent<E> c : pipelineComponents) {
            c.process(instance);
        }
        for (IBasePipelineComponent<E> c : pipelineComponents) {
            c.afterInstanceProcessing(instance);
        }
    }

    public void beforeProcessing() throws PipelineComponentException {
        //nop
    }

    public void afterProcessing() throws PipelineComponentException {
        //nop
    }
}
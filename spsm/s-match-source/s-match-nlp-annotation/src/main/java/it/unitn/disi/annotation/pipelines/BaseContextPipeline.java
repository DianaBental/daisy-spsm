package it.unitn.disi.annotation.pipelines;

import it.unitn.disi.common.pipelines.BasePipeline;
import it.unitn.disi.common.pipelines.IBasePipelineComponent;
import it.unitn.disi.smatch.data.trees.IBaseContext;

import java.util.List;

/**
 * Pipeline for contexts.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class BaseContextPipeline extends BasePipeline<IBaseContext> implements IBaseContextPipeline {

    public BaseContextPipeline(List<IBasePipelineComponent<IBaseContext>> pipelineComponents) {
        super(pipelineComponents);
    }
}
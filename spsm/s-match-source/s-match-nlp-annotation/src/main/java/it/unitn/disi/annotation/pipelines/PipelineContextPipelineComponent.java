package it.unitn.disi.annotation.pipelines;

import it.unitn.disi.annotation.data.INLPNode;
import it.unitn.disi.nlptools.ILabelPipeline;
import it.unitn.disi.nlptools.components.PipelineComponentException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.Label;
import it.unitn.disi.smatch.data.trees.IBaseContext;
import it.unitn.disi.smatch.data.trees.IBaseNode;
import it.unitn.disi.smatch.data.util.ProgressContainer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * Applies pipeline to all nodes. Warning: it creates a label with shared context, which changes after the label is
 * processed.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class PipelineContextPipelineComponent extends BaseContextPipelineComponent<INLPNode> {

    private static final Logger log = LoggerFactory.getLogger(PipelineContextPipelineComponent.class);

    private final ILabelPipeline pipeline;

    public PipelineContextPipelineComponent(ILabelPipeline pipeline) {
        this.pipeline = pipeline;
    }

    public void process(IBaseContext<INLPNode> instance) throws PipelineComponentException {
        //go DFS, processing node-by-node, keeping path-to-root as context
        if (null != instance.getRoot()) {
            ProgressContainer progressContainer = new ProgressContainer(instance.nodesCount(), log);

            ArrayList<INLPNode> queue = new ArrayList<>();
            ArrayList<IBaseNode> pathToRoot = new ArrayList<>();
            ArrayList<ILabel> pathToRootPhrases = new ArrayList<>();
            queue.add(instance.getRoot());

            while (!queue.isEmpty()) {
                INLPNode currentNode = queue.remove(0);
                if (null == currentNode) {
                    pathToRoot.remove(pathToRoot.size() - 1);
                    pathToRootPhrases.remove(pathToRootPhrases.size() - 1);
                } else {
                    ILabel currentPhrase;
                    currentPhrase = processNode(currentNode, pathToRootPhrases, progressContainer);

                    List<INLPNode> children = currentNode.getChildren();
                    if (0 < children.size()) {
                        queue.add(0, null);
                        pathToRoot.add(currentNode);
                        pathToRootPhrases.add(currentPhrase);
                    }
                    for (int i = children.size() - 1; i >= 0; i--) {
                        queue.add(0, children.get(i));
                    }
                }
            }
        }
    }

    protected ILabel processNode(INLPNode currentNode, ArrayList<ILabel> pathToRootPhrases, ProgressContainer progressContainer) {
        ILabel label = currentNode.nodeData().getLabel();
        if (null == label) {
            label = new Label(currentNode.nodeData().getName());
        }
        label.setContext(pathToRootPhrases);
        try {
            pipeline.process(label);
        } catch (PipelineComponentException e) {
            log.error(e.getMessage(), e);
        }
        currentNode.nodeData().setLabel(label);
        progressContainer.progress();
        return label;
    }
}
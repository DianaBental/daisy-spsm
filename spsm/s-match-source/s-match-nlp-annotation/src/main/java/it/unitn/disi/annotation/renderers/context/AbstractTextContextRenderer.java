package it.unitn.disi.annotation.renderers.context;

import it.unitn.disi.annotation.data.INLPContext;
import it.unitn.disi.annotation.data.INLPNode;
import it.unitn.disi.smatch.renderers.context.BaseFileContextRenderer;
import it.unitn.disi.smatch.renderers.context.ContextRendererException;

import java.io.BufferedWriter;
import java.io.IOException;
import java.util.Iterator;

/**
 * Abstract class for renderers of context in text format.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public abstract class AbstractTextContextRenderer extends BaseFileContextRenderer<INLPContext, INLPNode> implements INLPContextRenderer {

    public static final String TRAIN_FILES = "Train files (*.train)";

    protected AbstractTextContextRenderer() {
        super();
    }

    protected AbstractTextContextRenderer(boolean sort) {
        super(sort);
    }

    protected AbstractTextContextRenderer(String location, INLPContext context) {
        super(location, context);
    }

    protected AbstractTextContextRenderer(String location, INLPContext context, boolean sort) {
        super(location, context, sort);
    }

    @Override
    protected void process(INLPContext context, BufferedWriter out) throws IOException, ContextRendererException {
        processNode(context.getRoot(), out);
    }

    protected void processNode(INLPNode curNode, BufferedWriter out) throws IOException {
        if (Thread.currentThread().isInterrupted()) {
            return;
        }

        String toWrite = getTrainSample(curNode);
        if (null != toWrite) {
            out.write(toWrite);
            out.write("\n");
            progress();
        }
        Iterator<INLPNode> i = curNode.childrenIterator();
        while (i.hasNext()) {
            processNode(i.next(), out);
        }
    }

    protected abstract String getTrainSample(INLPNode curNode);

    public String getDescription() {
        return TRAIN_FILES;
    }
}
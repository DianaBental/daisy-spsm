package it.unitn.disi.annotation.renderers.context;

import it.unitn.disi.annotation.data.INLPContext;
import it.unitn.disi.annotation.data.INLPNode;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.smatch.async.AsyncTask;

/**
 * Renders context for OpenNLP POS tag trainer.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class POSTrainContextRenderer extends AbstractTextContextRenderer implements IAsyncNLPContextRenderer {

    public POSTrainContextRenderer() {
        super();
    }

    public POSTrainContextRenderer(boolean sort) {
        super(sort);
    }

    public POSTrainContextRenderer(String location, INLPContext context) {
        super(location, context);
    }

    public POSTrainContextRenderer(String location, INLPContext context, boolean sort) {
        super(location, context, sort);
    }

    @Override
    protected String getTrainSample(INLPNode curNode) {
        if (null != curNode.nodeData().getLabel()) {
            StringBuilder result = new StringBuilder();
            for (IToken token : curNode.nodeData().getLabel().getTokens()) {
                if (null != token.getPOSTag()) {
                    result.append(token.getText().replace(' ', '_')).append("_").append(token.getPOSTag()).append(" ");
                }
            }
            return result.substring(0, result.length() - 1);
        }
        return null;
    }

    @Override
    public AsyncTask<Void, INLPNode> asyncRender(INLPContext context, String location) {
        return new POSTrainContextRenderer(location, context, sort);
    }
}
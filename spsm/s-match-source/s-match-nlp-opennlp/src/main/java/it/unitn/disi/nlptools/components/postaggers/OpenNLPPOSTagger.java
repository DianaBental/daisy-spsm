package it.unitn.disi.nlptools.components.postaggers;

import it.unitn.disi.common.DISIException;
import it.unitn.disi.common.utils.MiscUtils;
import it.unitn.disi.nlptools.NLPToolsException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;
import opennlp.tools.postag.POSModel;
import opennlp.tools.postag.POSTaggerME;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;

/**
 * Tags the label using OpenNLP POS tagger.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class OpenNLPPOSTagger extends LabelPipelineComponent {

    private static final Logger log = LoggerFactory.getLogger(OpenNLPPOSTagger.class);

    private final POSTaggerME tagger;

    public OpenNLPPOSTagger(String modelFileName) throws NLPToolsException {
        if (log.isInfoEnabled()) {
            log.info("Loading model: " + modelFileName);
        }

        InputStream modelIn = null;
        try {
            modelIn = MiscUtils.getInputStream(modelFileName);
            POSModel model = new POSModel(modelIn);
            tagger = new POSTaggerME(model);
        } catch (IOException | DISIException e) {
            throw new NLPToolsException(e.getMessage(), e);
        } finally {
            if (modelIn != null) {
                try {
                    modelIn.close();
                } catch (IOException ignored) {
                }
            }
        }
    }

    public void process(ILabel instance) {
        String tokens[] = new String[instance.getTokens().size()];
        for (int i = 0; i < instance.getTokens().size(); i++) {
            tokens[i] = instance.getTokens().get(i).getText();
        }
        String[] tags = tagger.tag(tokens);
        for (int i = 0; i < instance.getTokens().size(); i++) {
            instance.getTokens().get(i).setPOSTag(tags[i]);
        }
    }
}
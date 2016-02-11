package it.unitn.disi.nlptools.components.tokenizers;

import it.unitn.disi.common.DISIException;
import it.unitn.disi.common.utils.MiscUtils;
import it.unitn.disi.nlptools.NLPToolsException;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.nlptools.data.Token;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;
import opennlp.tools.tokenize.Tokenizer;
import opennlp.tools.tokenize.TokenizerME;
import opennlp.tools.tokenize.TokenizerModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Tokenizes the label using OpenNLP tokenizer.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class OpenNLPTokenizer extends LabelPipelineComponent {

    private static final Logger log = LoggerFactory.getLogger(OpenNLPTokenizer.class);

    private final Tokenizer tokenizer;

    public OpenNLPTokenizer(String modelFileName) throws NLPToolsException {
        if (log.isInfoEnabled()) {
            log.info("Loading model: " + modelFileName);
        }

        InputStream modelIn = null;
        try {
            modelIn = MiscUtils.getInputStream(modelFileName);
            TokenizerModel model = new TokenizerModel(modelIn);
            tokenizer = new TokenizerME(model);
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
        String tokens[] = tokenizer.tokenize(instance.getText());
        List<IToken> tokenList = new ArrayList<>(tokens.length);
        for (String token : tokens) {
            tokenList.add(new Token(token));
        }
        instance.setTokens(tokenList);
    }
}
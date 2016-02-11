package it.unitn.disi.nlptools.components.tokenizers;

import it.unitn.disi.nlptools.NLPToolsConstants;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.nlptools.data.Token;
import it.unitn.disi.nlptools.pipelines.LabelPipelineComponent;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Implements simple rule-based tokenization.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class SimpleTokenizer extends LabelPipelineComponent {

    private final Pattern tokenPattern;

    public SimpleTokenizer() {
        this(NLPToolsConstants.DELIMITERS_EXCLUDING_BRACKETS);
    }

    public SimpleTokenizer(String delimiters) {
        this.tokenPattern = Pattern.compile(delimiters);
    }

    public void process(ILabel instance) {
        String[] tokens = tokenPattern.split(instance.getText());
        List<IToken> tokenList = new ArrayList<>(tokens.length);
        for (String token : tokens) {
            tokenList.add(new Token(token));
        }
        instance.setTokens(tokenList);
    }
}
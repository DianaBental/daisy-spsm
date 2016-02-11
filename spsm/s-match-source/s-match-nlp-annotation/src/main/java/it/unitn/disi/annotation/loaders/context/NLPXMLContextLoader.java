package it.unitn.disi.annotation.loaders.context;

import it.unitn.disi.annotation.data.INLPContext;
import it.unitn.disi.annotation.data.INLPNode;
import it.unitn.disi.annotation.data.NLPContext;
import it.unitn.disi.nlptools.data.ILabel;
import it.unitn.disi.nlptools.data.IToken;
import it.unitn.disi.nlptools.data.Label;
import it.unitn.disi.nlptools.data.Token;
import it.unitn.disi.smatch.async.AsyncTask;
import it.unitn.disi.smatch.data.ling.ISense;
import it.unitn.disi.smatch.loaders.context.BaseXMLContextLoader;
import it.unitn.disi.smatch.oracles.ILinguisticOracle;
import it.unitn.disi.smatch.oracles.LinguisticOracleException;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;

/**
 * Loads SimpleXML with labels.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class NLPXMLContextLoader extends BaseXMLContextLoader<INLPContext, INLPNode> implements INLPContextLoader, IAsyncNLPContextLoader {

    private final ILinguisticOracle oracle;

    // content handler variables
    // path to the root node
    protected final Deque<INLPNode> pathToRoot = new ArrayDeque<>();

    // label being read
    private ILabel label;
    // token being read
    private IToken token;

    public NLPXMLContextLoader() {
        super(true);
        this.oracle = null;
    }

    public NLPXMLContextLoader(ILinguisticOracle oracle) {
        super(true);
        this.oracle = oracle;
    }

    public NLPXMLContextLoader(boolean uniqueStrings, ILinguisticOracle oracle) {
        super(uniqueStrings);
        this.oracle = oracle;
    }

    public NLPXMLContextLoader(boolean uniqueStrings, ILinguisticOracle oracle, String location) {
        super(uniqueStrings, location);
        this.oracle = oracle;
    }

    @Override
    public AsyncTask<INLPContext, INLPNode> asyncLoad(String location) {
        return new NLPXMLContextLoader(isUniqueStrings(), oracle, location);
    }

    // content handler methods
    @Override
    public void startDocument() throws SAXException {
        super.startDocument();
        ctx = new NLPContext();
    }

    @Override
    public void startElement(String namespace, String localName, String qName, Attributes atts) throws SAXException {
        super.startElement(namespace, localName, qName, atts);
        switch (localName) {
            case "node":
                INLPNode node;
                if (null == ctx.getRoot()) {
                    node = ctx.createRoot();
                } else {
                    if (0 < pathToRoot.size()) {
                        node = pathToRoot.getLast().createChild();
                    } else {
                        // looks like there are multiple roots
                        INLPNode oldRoot = ctx.getRoot();
                        INLPNode newRoot = ctx.createRoot("Top");
                        newRoot.addChild(oldRoot);
                        node = newRoot.createChild();
                    }
                }
                node.nodeData().setId(atts.getValue("id"));
                pathToRoot.addLast(node);
                break;
            case "label":
                label = new Label();
                INLPNode n = pathToRoot.getLast();
                n.nodeData().setLabel(label);
                String text = atts.getValue("text");
                if (null == text) {
                    text = makeUnique(n.nodeData().getName());
                } else {
                    text = makeUnique(text);
                }
                label.setText(text);
                break;
            case "token":
                if (null != label) {
                    token = new Token();
                    if (0 == label.getTokens().size()) {
                        label.setTokens(new ArrayList<IToken>());
                    }
                    token.setText(atts.getValue("text"));
                    token.setPOSTag(atts.getValue("pos").intern());
                    label.getTokens().add(token);
                }
                break;
            case "sense":
                if (null != oracle) {
                    if (0 == token.getSenses().size()) {
                        token.setSenses(new ArrayList<ISense>());
                    }
                    try {
                        token.getSenses().add(oracle.createSense(atts.getValue("id")));
                    } catch (LinguisticOracleException e) {
                        throw new RuntimeException(e.getMessage(), e);
                    }
                }
                break;
            default:
                content = new StringBuilder();
                break;
        }
    }

    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        super.endElement(uri, localName, qName);
        switch (localName) {
            case "name":
                pathToRoot.getLast().nodeData().setName(makeUnique(content.toString()));
                break;
            case "formula":
                if (null != label) {
                    label.setFormula(content.toString());
                }
                break;
            case "label":
                label = null;
                break;
            case "token":
                token = null;
                break;
            case "node":
                pathToRoot.removeLast();

                progress();
                break;
        }
    }

    @Override
    public void endDocument() throws SAXException {
        super.endDocument();
        pathToRoot.clear();
    }
}
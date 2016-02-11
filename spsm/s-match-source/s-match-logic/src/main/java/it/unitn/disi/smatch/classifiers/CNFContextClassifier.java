package it.unitn.disi.smatch.classifiers;

import aima.core.logic.propositional.parsing.PLParser;
import aima.core.logic.propositional.parsing.ast.Sentence;
import aima.core.logic.propositional.visitors.ConvertToCNF;
import it.unitn.disi.smatch.async.AsyncTask;
import it.unitn.disi.smatch.data.trees.IContext;
import it.unitn.disi.smatch.data.trees.INode;
import it.unitn.disi.smatch.data.trees.INodeData;

import java.util.Iterator;

/**
 * Create concept at node formulas for each node of the context. Converts
 * concept at node formula into CNF.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class CNFContextClassifier extends BaseContextClassifier implements IAsyncContextClassifier {

    public CNFContextClassifier() {
        super();
    }

    public CNFContextClassifier(IContext context) {
        super(context);
    }

    protected void process(IContext context) throws ContextClassifierException {
        for (Iterator<INode> i = context.nodeIterator(); i.hasNext(); ) {
            if (Thread.currentThread().isInterrupted()) {
                break;
            }

            buildCNode(i.next());

            progress();
        }
    }

    @Override
    public AsyncTask<Void, INode> asyncClassify(IContext context) {
        return new CNFContextClassifier(context);
    }

    /**
     * Constructs c@node formula for the concept.
     *
     * @param in node to process
     * @throws ContextClassifierException ContextClassifierException
     */
    protected void buildCNode(INode in) throws ContextClassifierException {
        StringBuilder path = new StringBuilder();
        INodeData nd = in.nodeData();
        String formula = toCNF(nd.getLabelFormula());
        if (formula != null && !formula.isEmpty() && !formula.equals(" ")) {
            if (formula.contains(" ")) {
                formula = "(" + formula + ")";
            }
            path.append(formula);
        }
        if (in.hasParent()) {
            formula = in.getParent().nodeData().getNodeFormula();
            if (formula != null && !formula.isEmpty() && !formula.equals(" ")) {
                if (2 < path.length()) {
                    path.append(" & ").append(formula);
                } else {
                    path.append(formula);
                }
            }
        }

        nd.setNodeFormula(path.toString());
    }

    /**
     * Converts the formula into CNF.
     *
     * @param formula the formula to convert
     * @return formula in CNF form
     * @throws ContextClassifierException ContextClassifierException
     */
    public static String toCNF(String formula) throws ContextClassifierException {
        String result = formula;
        if ((formula.contains("&") && formula.contains("|")) || formula.contains("~")) {
            String tmpFormula = formula.trim();

            if (!tmpFormula.isEmpty()) {
                PLParser parser = new PLParser();
                Sentence f = parser.parse(tmpFormula);
                Sentence cnf = ConvertToCNF.convert(f);
                result = cnf.toString();
            } else {
                result = tmpFormula;
            }

        }
        return result;
    }
}
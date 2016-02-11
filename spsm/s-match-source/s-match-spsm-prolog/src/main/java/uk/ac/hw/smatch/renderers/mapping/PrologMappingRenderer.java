package uk.ac.hw.smatch.renderers.mapping;

import it.unitn.disi.smatch.data.mappings.IContextMapping;
import it.unitn.disi.smatch.data.mappings.IMappingElement;
import it.unitn.disi.smatch.data.trees.INode;
import it.unitn.disi.smatch.renderers.mapping.BaseFileMappingRenderer;
import it.unitn.disi.smatch.renderers.mapping.IMappingRenderer;

import java.io.BufferedWriter;
import java.io.IOException;

/**
 * Renders the mapping in Prolog-compatible format.
 *
 * @author Kristof Kessler <kkessler@staffmail.ed.ac.uk>
 * @author unknown original author
 */
public class PrologMappingRenderer extends BaseFileMappingRenderer implements IMappingRenderer {

    public final static String PROLOG_FILES = "Prolog Files (*.pl)";

    protected void process(IContextMapping<INode> mapping, BufferedWriter out) throws IOException {
        out.write("similarity(" + Double.toString(mapping.getSimilarity()) + ").\n");
        out.write("match(none).\n");

        for (IMappingElement<INode> mappingElement : mapping) {
            String sourceConceptName = getNodePathString(mappingElement.getSource());
            String targetConceptName = getNodePathString(mappingElement.getTarget());
            char relation = mappingElement.getRelation();

            out.write("match([[" + sourceConceptName + "]," + relation + ",[" + targetConceptName + "]]).\n");
        }
    }

    protected String getNodePathString(INode node) {
        StringBuilder sb = new StringBuilder();

        sb.insert(0, node.nodeData().getName());
        node = node.getParent();

        while (node != null) {
            sb.insert(0, node.nodeData().getName() + ",");
            node = node.getParent();
        }

        return sb.toString();
    }

    public String getDescription() {
        return PROLOG_FILES;
    }
}

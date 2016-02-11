package it.unitn.disi.smatch.renderers.mapping;

import it.unitn.disi.smatch.data.mappings.IContextMapping;
import it.unitn.disi.smatch.data.mappings.IMappingElement;
import it.unitn.disi.smatch.data.trees.INode;
import it.unitn.disi.smatch.loaders.ILoader;
import org.apache.log4j.Logger;

import java.io.BufferedWriter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * Renders the mapping in a plain text file.
 * Format: source-node tab relation target-node.
 * Source and target nodes are rendered with \ separating path to root levels.
 *
 * @author Aliaksandr Autayeu avtaev@gmail.com
 */
public class PrologMappingRenderer extends BaseFileMappingRenderer implements IMappingRenderer
{
    protected void process(IContextMapping<INode> mapping, BufferedWriter out) throws IOException
    {
        out.write("similarity(" + Double.toString(mapping.getSimilarity()) + ").\n");
        out.write("match(none).\n");

        for (IMappingElement<INode> mappingElement : mapping)
        {
            String sourceConceptName = getNodePathString(mappingElement.getSource());
            String targetConceptName = getNodePathString(mappingElement.getTarget());
            char relation = mappingElement.getRelation();
            
            out.write("match([[" + sourceConceptName + "]," + relation + ",[" + targetConceptName + "]]).\n");

            countRelation(relation);
            reportProgress();
        }
    }
    
    protected String getNodePathString(INode node)
    {
        StringBuilder sb = new StringBuilder();

        sb.insert(0, node.getNodeData().getName());
        node = node.getParent();
        
        while (node != null)
        {
            sb.insert(0, node.getNodeData().getName() + ",");
            node = node.getParent();
        }

        return sb.toString();
    }

    public String getDescription()
    {
        return ILoader.TXT_FILES;
    }
}

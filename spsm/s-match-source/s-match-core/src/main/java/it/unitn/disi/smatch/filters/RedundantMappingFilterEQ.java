package it.unitn.disi.smatch.filters;

import it.unitn.disi.smatch.async.AsyncTask;
import it.unitn.disi.smatch.data.mappings.IContextMapping;
import it.unitn.disi.smatch.data.mappings.IMappingElement;
import it.unitn.disi.smatch.data.mappings.IMappingFactory;
import it.unitn.disi.smatch.data.trees.INode;

/**
 * Filters the mapping, expanding equivalence links into pairs of more general and less general links.
 * <p/>
 * For more details see:
 * <p/>
 * <a href="http://eprints.biblio.unitn.it/archive/00001525/">http://eprints.biblio.unitn.it/archive/00001525/</a>
 * <p/>
 * Giunchiglia, Fausto and Maltese, Vincenzo and Autayeu, Aliaksandr. Computing minimal mappings.
 * Technical Report DISI-08-078, Department of Information Engineering and Computer Science, University of Trento.
 * Proc. of the Fourth Ontology Matching Workshop at ISWC 2009.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class RedundantMappingFilterEQ extends RedundantMappingFilter {

    public RedundantMappingFilterEQ(IMappingFactory mappingFactory) {
        super(mappingFactory);
    }

    public RedundantMappingFilterEQ(IMappingFactory mappingFactory, IContextMapping<INode> mapping) {
        super(mappingFactory, mapping);
    }

    @Override
    public AsyncTask<IContextMapping<INode>, IMappingElement<INode>> asyncFilter(IContextMapping<INode> mapping) {
        return new RedundantMappingFilterEQ(mappingFactory, mapping);
    }

    // because in filtering we do not "discover" links
    // we need to check ancestors and descendants, and not only parents and children
    // otherwise, in case of series of redundant links we remove the first one by checking parent
    // and then all the rest is not removed because of the "gap"

    protected boolean verifyCondition1(IContextMapping<INode> mapping, IMappingElement<INode> e) {
        return findRelation(IMappingElement.LESS_GENERAL, e.getSource().ancestorsIterator(), e.getTarget(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource().ancestorsIterator(), e.getTarget(), mapping) ||

                findRelation(IMappingElement.LESS_GENERAL, e.getSource(), e.getTarget().descendantsIterator(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource(), e.getTarget().descendantsIterator(), mapping) ||

                findRelation(IMappingElement.LESS_GENERAL, e.getSource().ancestorsIterator(), e.getTarget().descendantsIterator(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource().ancestorsIterator(), e.getTarget().descendantsIterator(), mapping);
    }

    protected boolean verifyCondition2(IContextMapping<INode> mapping, IMappingElement<INode> e) {
        return findRelation(IMappingElement.MORE_GENERAL, e.getSource(), e.getTarget().ancestorsIterator(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource(), e.getTarget().ancestorsIterator(), mapping) ||

                findRelation(IMappingElement.MORE_GENERAL, e.getSource().descendantsIterator(), e.getTarget(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource().descendantsIterator(), e.getTarget(), mapping) ||

                findRelation(IMappingElement.MORE_GENERAL, e.getSource().descendantsIterator(), e.getTarget().ancestorsIterator(), mapping) ||
                findRelation(IMappingElement.EQUIVALENCE, e.getSource().descendantsIterator(), e.getTarget().ancestorsIterator(), mapping);
    }
}

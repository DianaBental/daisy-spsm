package it.unitn.disi.smatch.data.mappings;

import it.unitn.disi.smatch.data.trees.IContext;

/**
 * Interface for context mappings.
 *
 * @author Aliaksandr Autayeu avtaev@gmail.com
 */
public interface IContextMapping<T> extends IMapping<T> {

    IContext getSourceContext();

    IContext getTargetContext();

}

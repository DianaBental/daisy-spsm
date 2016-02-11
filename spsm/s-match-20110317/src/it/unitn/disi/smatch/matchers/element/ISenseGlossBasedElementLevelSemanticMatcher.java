package it.unitn.disi.smatch.matchers.element;

import it.unitn.disi.smatch.components.IConfigurable;
import it.unitn.disi.smatch.oracles.ISynset;

/**
 * An interface for sense and gloss based element level matchers.
 *
 * @author Mikalai Yatskevich mikalai.yatskevich@comlab.ox.ac.uk
 * @author Aliaksandr Autayeu avtaev@gmail.com
 */
public interface ISenseGlossBasedElementLevelSemanticMatcher extends IConfigurable {

    /**
     * Returns a relation between source and target synsets.
     *
     * @param source interface of source synset
     * @param target interface of target synset.
     * @return a relation between source and target synsets
     * @throws MatcherLibraryException MatcherLibraryException
     */
    char match(ISynset source, ISynset target) throws MatcherLibraryException;
}

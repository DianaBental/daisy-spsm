package it.unitn.disi.smatch.oracles.wordnet;

import it.unitn.disi.smatch.oracles.ISynset;
import it.unitn.disi.smatch.oracles.LinguisticOracleException;
import net.didion.jwnl.JWNLException;
import net.didion.jwnl.data.PointerUtils;
import net.didion.jwnl.data.Synset;
import net.didion.jwnl.data.list.PointerTargetNode;
import net.didion.jwnl.data.list.PointerTargetNodeList;
import net.didion.jwnl.data.list.PointerTargetTree;
import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * WordNet-based synset implementation.
 *
 * @author Mikalai Yatskevich mikalai.yatskevich@comlab.ox.ac.uk
 * @author Aliaksandr Autayeu avtaev@gmail.com
 */
public class WordNetSynset implements ISynset {

    private static final Logger log = Logger.getLogger(WordNetSynset.class);

    private Synset tmp;

    /**
     * Constructor class with sense input.
     *
     * @param sense input sense
     */
    public WordNetSynset(Synset sense) {
        tmp = sense;
    }


    public String getGloss() {
        return tmp.getGloss();
    }

    public List<String> getLemmas() {
        List<String> out = new ArrayList<String>();
        String lemmaToCompare;

        for (int i = 0; i < tmp.getWordsSize(); i++) {
            lemmaToCompare = tmp.getWord(i).getLemma();
            out.add(lemmaToCompare);
        }

        return out;
    }

    public List<ISynset> getParents() throws LinguisticOracleException {
        List<ISynset> out = new ArrayList<ISynset>();
        try {
            PointerUtils pu = PointerUtils.getInstance();
            PointerTargetTree hypernyms = pu.getHypernymTree(tmp, 1);
            for (Iterator itr = hypernyms.toList().iterator(); itr.hasNext();) {
                if (itr.hasNext()) {
                    for (Object o : ((PointerTargetNodeList) itr.next())) {
                        Synset t = ((PointerTargetNode) o).getSynset();
                        if (!isEqual(tmp, t)) {
                            out.add(new WordNetSynset(t));
                        }
                    }
                }
            }
        } catch (JWNLException e) {
            final String errMessage = e.getClass().getSimpleName() + ": " + e.getMessage();
            log.error(errMessage, e);
            throw new LinguisticOracleException(errMessage, e);
        }
        return out;
    }

    public List<ISynset> getParents(int depth) throws LinguisticOracleException {
        List<ISynset> out = new ArrayList<ISynset>();
        try {
            PointerUtils pu = PointerUtils.getInstance();
            PointerTargetTree hypernyms = pu.getHypernymTree(tmp, depth);
            for (Iterator itr = hypernyms.toList().iterator(); itr.hasNext();) {
                if (itr.hasNext()) {
                    for (Object o : ((PointerTargetNodeList) itr.next())) {
                        Synset t = ((PointerTargetNode) o).getSynset();
                        if (!isEqual(tmp, t)) {
                            out.add(new WordNetSynset(t));
                        }
                    }
                }
            }
        } catch (JWNLException e) {
            final String errMessage = e.getClass().getSimpleName() + ": " + e.getMessage();
            log.error(errMessage, e);
            throw new LinguisticOracleException(errMessage, e);
        }
        return out;
    }

    public List<ISynset> getChildren() throws LinguisticOracleException {
        List<ISynset> out = new ArrayList<ISynset>();
        try {
            PointerUtils pu = PointerUtils.getInstance();
            PointerTargetTree hypernyms = pu.getHyponymTree(tmp, 1);
            for (Iterator itr = hypernyms.toList().iterator(); itr.hasNext();) {
                if (itr.hasNext()) {
                    for (Object o : ((PointerTargetNodeList) itr.next())) {
                        Synset t = ((PointerTargetNode) o).getSynset();
                        if (!isEqual(tmp, t)) {
                            out.add(new WordNetSynset(t));
                        }
                    }
                }
            }
        } catch (JWNLException e) {
            final String errMessage = e.getClass().getSimpleName() + ": " + e.getMessage();
            log.error(errMessage, e);
            throw new LinguisticOracleException(errMessage, e);
        }
        return out;
    }

    public List<ISynset> getChildren(int depth) throws LinguisticOracleException {
        List<ISynset> out = new ArrayList<ISynset>();
        try {
            PointerUtils pu = PointerUtils.getInstance();
            PointerTargetTree hypernyms = pu.getHyponymTree(tmp, depth);
            for (Iterator itr = hypernyms.toList().iterator(); itr.hasNext();) {
                if (itr.hasNext()) {
                    for (Object o : ((PointerTargetNodeList) itr.next())) {
                        Synset t = ((PointerTargetNode) o).getSynset();
                        if (!isEqual(tmp, t)) {
                            out.add(new WordNetSynset(t));
                        }
                    }
                }
            }
        } catch (JWNLException e) {
            final String errMessage = e.getClass().getSimpleName() + ": " + e.getMessage();
            log.error(errMessage, e);
            throw new LinguisticOracleException(errMessage, e);
        }
        return out;
    }

    public boolean isEqual(Synset source, Synset target) {
        long so = source.getOffset();
        long to = target.getOffset();
        String sourcePOS = source.getPOS().toString();
        String targetPOS = target.getPOS().toString();
        return ((sourcePOS.equals(targetPOS)) && (so == to));
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof WordNetSynset)) return false;

        final WordNetSynset wordNetSynset = (WordNetSynset) o;

        if (tmp != null ? !tmp.equals(wordNetSynset.tmp) : wordNetSynset.tmp != null) return false;

        return true;
    }

    public int hashCode() {
        return (tmp != null ? tmp.hashCode() : 0);
    }
}
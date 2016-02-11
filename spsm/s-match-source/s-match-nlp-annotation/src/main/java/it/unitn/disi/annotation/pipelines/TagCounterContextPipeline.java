package it.unitn.disi.annotation.pipelines;

import it.unitn.disi.annotation.pipelines.components.TagCounter;
import it.unitn.disi.common.pipelines.IBasePipelineComponent;
import it.unitn.disi.nlptools.components.PipelineComponentException;
import it.unitn.disi.smatch.data.trees.IBaseContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * Reports tag counts.
 *
 * @author <a rel="author" href="http://autayeu.com/">Aliaksandr Autayeu</a>
 */
public class TagCounterContextPipeline extends BaseContextPipeline {

    private static final Logger log = LoggerFactory.getLogger(TagCounterContextPipeline.class);

    public TagCounterContextPipeline(List<IBasePipelineComponent<IBaseContext>> pipelineComponents) {
        super(pipelineComponents);
    }

    @Override
    public void beforeProcessing() throws PipelineComponentException {
        TagCounter.getTagCounts().clear();
        super.beforeProcessing();
    }

    @Override
    public void afterProcessing() throws PipelineComponentException {
        super.afterProcessing();
        Map<String, Long> tagCounts = TagCounter.getTagCounts();
        //sort by counts and print
        MapValueComparator<String, Long> mvc = new MapValueComparator<>(tagCounts);
        ArrayList<String> tags = new ArrayList<>(tagCounts.keySet());
        Collections.sort(tags, mvc);

        for (String tag : tags) {
            log.info(tag + "\t" + tagCounts.get(tag));
        }
    }

    private static class MapValueComparator<A, B extends Comparable<? super B>> implements Comparator<A> {

        private final Map<A, B> base;

        public MapValueComparator(Map<A, B> base) {
            this.base = base;
        }

        public int compare(A a, A b) {
            return base.get(b).compareTo(base.get(a));
        }
    }
}
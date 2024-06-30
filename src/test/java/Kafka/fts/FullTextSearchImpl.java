package Kafka.fts;


import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class FullTextSearchImpl implements FullTextSearch {

    private final InvertedIndex index;
    private final List<Message> source;

    public FullTextSearchImpl(List<Message> source){
        this(InvertedIndexImpl.jsonIndex(), source);
    }

    public FullTextSearchImpl(InvertedIndex index, List<Message> source) {
        this.index = index;
        this.source = source;
        index.index(source);
    }

    @Override
    public List<Message> search(String text) {
        Set<Long> ids = index.idsForToken(text);
        List<Message> collect = source.stream()
                .filter(message -> ids.contains(message.offset()))
                .collect(Collectors.toList());
        System.out.println(collect);
        return collect;
    }

}

package Kafka.fts;

import java.util.Collection;
import java.util.Set;

public interface InvertedIndex {

    void index(Collection<Message> source);

    Set<Long> idsForToken(String token);

}

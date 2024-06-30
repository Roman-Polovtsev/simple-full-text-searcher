package Kafka.fts;

import java.util.List;

public interface FullTextSearch {
    
    List<Message> search(String text);
}

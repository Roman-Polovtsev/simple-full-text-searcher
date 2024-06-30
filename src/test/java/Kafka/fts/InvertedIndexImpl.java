package Kafka.fts;

import java.util.*;

public class InvertedIndexImpl implements InvertedIndex {

    private final Map<String, Set<Long>> index;
    private final Tokenizer tokenizer;

    public static InvertedIndexImpl jsonIndex(){
        return new InvertedIndexImpl(new HashMap<>(), new JsonTokenizer());
    }

     public InvertedIndexImpl(){
         this(new HashMap<>(), new StandardTokenizer());
     }

    public InvertedIndexImpl(Map<String, Set<Long>> index, Tokenizer tokenizer) {
        this.index = index;
        this.tokenizer = tokenizer;
    }

    @Override
    public void index(Collection<Message> messages) {
        messages.forEach(this::indexMessage);
    }

    @Override
    public Set<Long> idsForToken(String token){
        Set<Long> appearances = index.get(token);
        if(appearances == null)
            return new HashSet<>();
        else return appearances;
    }

    private void indexMessage(Message message) {
        tokenizer.tokenize(message.data())
                .forEach(token -> putToken(token, message.offset()));
    }

    private void putToken(String token, long messageId) {
        Set<Long> messageIds = index.get(token);
        if (messageIds == null){
            HashSet<Long> ids = new HashSet<>();
            ids.add(messageId);
            index.put(token, ids);
        } else {
            messageIds.add(messageId);
        }
    }

}

package Kafka.fts;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;


public class FullTextSearchTest {

    private static final List<String> SOURCE = Stream.of(
            "А роза упала на лапу азора",
            "розовая роза Светке Соколовой",
            "миллион алых роз",
            "один на миллион",
            "город-миллионник Уфа - это город в котором миллион жителей",
            "Москва не очень, а Уфа - кайф").collect(Collectors.toList());

    public static void main(String[] args) {
        List<Message> source = IntStream.range(0, SOURCE.size())
                .mapToObj(i -> Message.from(new ConsumerRecord<>("topic", 1, i, "key", SOURCE.get(i))))
                .collect(Collectors.toList());
        InvertedIndexImpl index = new InvertedIndexImpl();
        index.index(source);
        FullTextSearch fts = new FullTextSearchImpl(index, source);

        List<Message> rose = fts.search("роза");
        List<Message> ufaCity = fts.search("Уфа");
        List<Message> million = fts.search("миллион");

        System.out.println(rose);
        System.out.println(ufaCity);
        System.out.println(million);
    }

    @Test
    public void ftsTest() {
        List<Message> source = IntStream.range(0, SOURCE.size()-1)
                .mapToObj(i -> Message.from(new ConsumerRecord<>("topic", 1, i, "key", SOURCE.get(i))))
                .collect(Collectors.toList());
        InvertedIndexImpl index = new InvertedIndexImpl();
        index.index(source);
        FullTextSearch fts = new FullTextSearchImpl(index, source);

        List<Message> rose = fts.search("роза");
        List<Message> ufaCity = fts.search("Уфа");
        List<Message> million = fts.search("миллион");

        System.out.println(rose);
        System.out.println(ufaCity);
        System.out.println(million);
    }


}

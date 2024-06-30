package Kafka.fts;


import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class StandardTokenizer implements Tokenizer {

    private static final String DELIMITER = " ";

    @Override
    public List<String> tokenize(String text) {
        return Arrays.stream(text.split(DELIMITER)).collect(Collectors.toList());
    }
}

package Kafka.fts;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class JsonTokenizer implements Tokenizer {

    private static final Pattern PATTERN = Pattern.compile("\\[\"(.*?)\"\\]");

    @Override
    public List<String> tokenize(String text) {
        String replace1 = text.replace("\"{", "");
        String replace2 = replace1.replace("}\"", "");
        String[] jsonPairs = replace2.split(",");
        List<String> collect = Arrays.stream(jsonPairs)
                .flatMap(this::splitToTokens)
                .map(this::ignorePunctuation)
                .map(String::trim)
                .flatMap(this::splitLargeValuesToTokens)
                .collect(Collectors.toList());
        System.out.println(collect);
        return collect;
    }

    private Stream<String> splitLargeValuesToTokens(String s) {
        if( s.contains(" "))
            return Arrays.stream(s.split(" "));
        else return Stream.of(s);
    }

    private  String ignorePunctuation(String s) {
        return s.replace(",", "").replace("\"","");
    }

    private  Stream<String> splitToTokens(String s) {
        return Arrays.stream(s.split(":"));
    }
}

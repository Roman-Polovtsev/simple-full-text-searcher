package ru.polovtsev.test;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

//return list of unique hash tags
//result shoul be sorted inby usge fequesnce
public class HashTags {

    public List<String> tags(List<String> strings){
        final HashMap<String, Integer> countMap = new HashMap<>();
        return strings.stream()
            .flatMap(string -> Arrays.stream(string.split(" ")))
            .filter(word -> word.startsWith("#"))
            .peek(s -> populateMap(s, countMap))
            .sorted(Comparator.comparing(countMap::get, Integer::compareTo).reversed())
            .distinct()
            .collect(Collectors.toList());
    }

    private void populateMap(String s, Map<String,Integer> map) {
        map.put(s, map.getOrDefault(s,0) + 1);
    }

    ;

    public static void main(String[] args) {
        List<String> strings = List.of(
            "#Java is best #programming language in the world",
            "Island of #Java is the one who gave a name for a #programming language",
            "The other one is #Kotlin - it gave a name for mobile development #programming langage");
        List<String> tags = new HashTags().tags(strings);
        System.out.println(tags);
    }
}

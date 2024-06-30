package ru.polovtsev.tests;

import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class MultiMap {

    /*
    multimap
    1- >[0,1,2]
    2- >[3,4]

    output:
        0->1
        1->1
        2->1
        3->2
        4->2
     */

    public Map<Long, Integer> doSmth(final Map<Integer, List<Long>> map){
       return map.entrySet().stream().flatMap(entry -> {
           Integer value = entry.getKey();
           return entry.getValue().stream().map(key -> Map.entry(key,value));
       }).collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }

    public static class X{
        final String name;
        final List<Integer> value;

        public X(String name, List<Integer> value) {
            this.name = name;
            this.value = value;
        }

        public String getName() {
            return name;
        }

        public List<Integer> getValue() {
            return value;
        }
    }

    public static void main(String[] args) {
        var map = new HashMap<Integer, List<Long>>();
        map.put(1, Arrays.asList(0L,1L,2L));
        map.put(2, Arrays.asList(3L,4L));
        Map<Long, Integer> res = new MultiMap().doSmth(map);
        System.out.println(res);

        Stream<X> stream = Stream.of(new X("a", List.of(23)), new X("sfasf", List.of(43, 23)));
        Predicate
        Comparator<X> custom = new Comparator<X>() {
            @Override public int compare(X o1, X o2) {

                return o1.getValue().stream().findAny()
            }
        }
        stream.sorted(Comparator.comparing())

    }
}

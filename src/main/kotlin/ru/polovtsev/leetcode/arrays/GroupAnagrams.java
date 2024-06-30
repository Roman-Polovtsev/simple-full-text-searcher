package ru.polovtsev.leetcode.arrays;

import ru.polovtsev.generics.A;
import ru.polovtsev.leetcode.binaryTree.SameTree;

import java.util.*;
import java.util.stream.Collectors;

public class GroupAnagrams {
    public List<List<String>> groupAnagrams(String[] strs) {
        if (strs == null || strs.length == 0) return new ArrayList<>();
        Map<String, List<String>> map = new HashMap<>();
        for (String str : strs) {
            char[] chars = str.toCharArray();
            Arrays.sort(chars);
            String sorted = new String(chars);
            map.compute(sorted, (k,v)-> {
                if (v == null) {
                    ArrayList<String> value = new ArrayList<>();
                    value.add(str);
                    return value;
                } else {
                    v.add(str);
                    return v;
                }
            });
        }
        return new ArrayList<>(map.values());
    }

    public List<List<String>> groupAnagramsOptimal(String[] strs) {
        if (strs == null || strs.length == 0) return new ArrayList<>();
        Map<String, List<String>> map = new HashMap<>();
        for (String str : strs) {

            String sgn = computeSignature(str);
            map.computeIfAbsent(sgn, k -> new ArrayList<>()).add(str);
        }
        return new ArrayList<>(map.values());
    }

    private String computeSignature(String str) {
        int[] chars = new int[26]; //alpahbet symbols
        for (char c : str.toCharArray()) {
            chars[c - 'a']++; //add if there is an occurence
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < 26; i++) {
            if (chars[i] > 0)
                builder.append((char) ('a' + i))
                        .append(chars[i]); //added for cases like: abbb , bbba - without this line both
            // have sgn = ab without counting quantity of symbols
            }
        return builder.toString();
    }


    public static void main(String[] args) {
        String[] strings0 = {"eat", "tea", "tan", "ate", "nat", "bat"};
        String[] strings = {"ddddddddddg","dgggggggggg"};
        String[] strings1 = {""};
        String[] strings2 = {"a"};
        List<List<String>> list = new GroupAnagrams().groupAnagramsOptimal(strings);
        List<List<String>> list2 = new GroupAnagrams().groupAnagrams(strings1);
        List<List<String>> list3 = new GroupAnagrams().groupAnagrams(strings2);
        list.forEach(System.out::println);
        list2.forEach(System.out::println);
        list3.forEach(System.out::println);
    }
}

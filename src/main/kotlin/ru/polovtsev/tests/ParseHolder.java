package ru.polovtsev.tests;

import java.util.Arrays;
import java.util.HashMap;

public class ParseHolder {

    /*
    Написать парсер строки с функциями:
    1) достать по ключу занчение за О(1)
    2) выдавать исходную строку
    3)
     */
    private final HashMap<String, String> map = new HashMap<>();
    private String original;

    void parse(String s){
        original = s;
        Arrays.stream(s.split(";"))
            .map(String::trim)
            .forEach(str -> {
                String[] res = str.split("=");
                map.put(res[0], res[1]);
            });
    }

    String generateRecord(){
        return original;
    }

    public String getValue(String key){
        return map.get(key);
    }


    public static void main(String[] args) {
        String testString  = "key1=val1;key1=abc;key2=val2;key3=val3; " +
            "key1=val4;key2=val5;key1=val6";
        ParseHolder parseHolder = new ParseHolder();
        parseHolder.parse(testString);
        System.out.println(parseHolder.generateRecord());
    }
}

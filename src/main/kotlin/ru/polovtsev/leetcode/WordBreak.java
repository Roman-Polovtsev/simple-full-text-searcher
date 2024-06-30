package ru.polovtsev.leetcode;

import java.util.ArrayList;
import java.util.List;

public class WordBreak {

//    public boolean wordBreak(String s, List<String> wordDict){
//        int length = s.length();
//        List<String> memo = new ArrayList<>();
//        for (String word : wordDict){
//            if (s.contains(word)){
//                int wordLength = word.length();
//                memo.add(word);
//                for (int i = length - wordLength; i <= length; i++){
//
//                }
//            } else  return false;
//        }
//    }

    public boolean wordBreak1(String s, List<String> wordDict) {
        var curr = 0;
        var i = 0;
        var length = s.length();
        var resTemp = false;
        var res = false;
        var  memo = new ArrayList<String>();

        while (i <= length ){
            var sub = s.substring(curr, i);
            if (wordDict.contains(sub)){
                curr = i;
                resTemp = true;
                memo.add(sub);
                if (i == length){
                    res = true;
                }
            }
            i++;
        }
        return resTemp & res;
    }



//    public static void main(String[] args) {
//        WordBreak wordBreak = new WordBreak();
//        boolean res = wordBreak.wordBreak("aaaaaaa", List.of("aaaa", "aaa"));
//        System.out.println(res);
//    }
}

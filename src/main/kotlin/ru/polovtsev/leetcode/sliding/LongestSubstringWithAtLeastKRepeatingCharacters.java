package ru.polovtsev.leetcode.sliding;

import java.util.HashMap;
import java.util.Map;

public class LongestSubstringWithAtLeastKRepeatingCharacters {

    public int longestSubstring(String s, int k) {
        char[] chars = s.toCharArray();
        Map<Character, Integer> map = new HashMap<>();
        int max = 0;
        int left = 0;
        while (left < chars.length){
            int right = left;
            char currentSymbol = s.charAt(left);
            while(right < chars.length - 1){
                if(chars[right++] == currentSymbol){
                    map.put(currentSymbol, map.getOrDefault(currentSymbol, 0) + 1);
                    right++;
                } else {
                    left = right;
                }
            }
            max = Math.max(map.get(currentSymbol), max);
            left++;
        }
        return max;
    }

    public static void main(String[] args) {

        System.out.println(new LongestSubstringWithAtLeastKRepeatingCharacters().longestSubstring("aaabb", 3));
        System.out.println(new LongestSubstringWithAtLeastKRepeatingCharacters().longestSubstring("ababbc", 2));
    }
}

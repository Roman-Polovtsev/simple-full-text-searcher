package ru.polovtsev.leetcode.sliding;

import java.util.HashMap;
import java.util.HashSet;

public class LongestSubstringWithoutRepeatingCharacters3 {
    public int lengthOfLongestSubstring(String s) {
        var set = new HashSet<Character>();
        var left = 0;
        var right = 0;
        var max = 0;
        HashMap<Integer, Integer> map = new HashMap<>();
        map.put(1, map.getOrDefault(1, 0));
        while (right < s.length()) {
            char currentSymbol = s.charAt(right);
            if (!set.contains(currentSymbol)){
                set.add(currentSymbol);
                max = Math.max(max, set.size());
                right++;
            } else {
                char existingSymbol = s.charAt(left);
                set.remove(existingSymbol);
                left++;
            }
        }
        return max;
    }
//    a,

    public static void main(String[] args) {
        LongestSubstringWithoutRepeatingCharacters3 a = new LongestSubstringWithoutRepeatingCharacters3();
        int res = a.lengthOfLongestSubstring("abcabcbb");
        System.out.println(res);
    }
}

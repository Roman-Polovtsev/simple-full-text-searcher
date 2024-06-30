package ru.polovtsev.leetcode.stack;



/*
    Example 1:

    Input: s = "()"
    Output: true
    Example 2:

    Input: s = "()[]{}"
    Output: true
    Example 3:

    Input: s = "(]"
    Output: false
 */

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Stack;

public class ValidParentheses {
    public boolean isValid(String s) {
        Map<Character, Character> charsMap = Map.of('{', '}', '[', ']', '(', ')');
        char[] chars = s.toCharArray();
        int length = s.length();
        if (length %2 == 1) return false;
        Stack<Character> stack = new Stack<>();
        for (int i = 0; i < length / 2; i++) {
            stack.push(chars[i]);
        }
        for (int i = length/2; i < length; i++) {
            Character res = stack.pop();
            System.out.println(res);
            Character fromMap = charsMap.get(res);
            System.out.println(fromMap);
            if (fromMap != chars[i]) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {
        String s = "(]";
        ValidParentheses parentheses = new ValidParentheses();
        boolean valid = parentheses.isValid(s);
        System.out.println(valid);
    }
}



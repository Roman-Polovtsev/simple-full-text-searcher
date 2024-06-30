package ru.polovtsev.leetcode;

public class BackspaceString {

    public boolean backspaceCompare(String s, String t) {
        String s1 = computeString(s);
        String s2 = computeString(t);
        System.out.println("s2 = " + s2);
        System.out.println("t = " + s1);
        return s1.equals(s2);
    }

    // abc#d
    private String computeString(String s){
        int backspaceCounter = 0;
        StringBuilder stringBuilder = new StringBuilder();
        char[] chars = s.toCharArray();
        for (int i = chars.length -1 ; i >= 0; i--) {
              if (chars[i] == '#') {
                  backspaceCounter++;
              } else {
                  if (backspaceCounter == 0) {
                      stringBuilder.append(chars[i]);
                  } else if (backspaceCounter > 0) {
                      backspaceCounter--;
                  }
              }
        }
        return stringBuilder.reverse().toString();
    }

    public static void main(String[] args) {
        BackspaceString backspaceString = new BackspaceString();
        System.out.println(backspaceString.backspaceCompare("ab#c", "ad#c"));
        System.out.println(backspaceString.backspaceCompare("ab##", "c#d#"));
        System.out.println(backspaceString.backspaceCompare("a#c", "b"));
    }
}

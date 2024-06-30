package ru.polovtsev.leetcode.trie;
import java.util.HashMap;
public class LongestPrefix {

    // "flower","flow","flight"
      static StringBuilder max;

     public static void main(String[] args) {
    LongestPrefix prefix = new LongestPrefix();
//            String s = prefix.longestCommonPrefix(new String[]{"flower", "flow", "flight"});
//            String s1 = prefix.longestCommonPrefix(new String[]{"dog","racecar","car"});
            String s2 = prefix.longestCommonPrefix(new String[]{"a"});
//            System.out.println(s);
            System.out.println(s2);
     }


    /*    '' -> f -> l     */
    Node root;

    public String longestCommonPrefix(String[] strs) {
        max = new StringBuilder();
        root = new Node();
        for (String s: strs){
            root.add(s,0);
        }
        return root.maxLength();
    }

    static class Node{
        HashMap<Character, Node> children = new HashMap<>();
        boolean isLast;

        public void add(String s, int index){
            if (index >= s.length()) return;
            char currentSymbol = s.charAt(index);
            if (!children.containsKey(currentSymbol)){
                children.put(currentSymbol, new Node());
            }
            if (index == s.length()-1) {
                children.get(currentSymbol).isLast = true;
                return;
            }

            children.get(currentSymbol).add(s, index + 1);
        }

        public String maxLength(){
            return helper(children);        }

        private String helper(HashMap<Character,Node> current){
            if (current.size() != 1)
                return max.toString();
            var isLast = current.values().iterator().next().isLast;

            //additional check if current element is last - it could not be a prefix
            if (isLast)
                return max.toString();
            max.append(current.keySet().iterator().next());
            return helper(current.values().iterator().next().children);
        }
    }


}

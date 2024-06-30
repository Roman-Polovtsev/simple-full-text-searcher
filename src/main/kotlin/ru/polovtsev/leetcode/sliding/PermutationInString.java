package ru.polovtsev.leetcode.sliding;

public class PermutationInString {

    public boolean checkInclusion(String s1, String s2) {
        return false;
    }

    public static void main(String[] args) {
        PermutationInString permutation = new PermutationInString();
        permutation.checkInclusion("ab", "eidbaooo");
        permutation.checkInclusion("ab", "eidboaoo");
    }
}

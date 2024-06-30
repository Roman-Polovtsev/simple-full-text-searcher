package ru.polovtsev.leetcode;

import java.util.List;

public class Subsets {

    //
    private void backtrack(){

    }

    public List<List<Integer>> subsets(int[] nums) {
        //new int[]
        return null;
    }

    public static void main(String[] args) {
        int[] first = {1, 2, 3};
        int[] second = {0};
        Subsets subsets = new Subsets();
        //[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]
        System.out.println(subsets.subsets(first));
        //[[],[0]]
        System.out.println(subsets.subsets(second));
    }
}

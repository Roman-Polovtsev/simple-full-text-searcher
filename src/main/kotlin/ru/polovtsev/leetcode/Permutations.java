package ru.polovtsev.leetcode;

import java.util.ArrayList;
import java.util.List;

public class Permutations {

    List<List<Integer>> permuteList = new ArrayList<>();

    private void backtrack(int[] nums, List<Integer> currentPermutation){
        //stop condition
        if (currentPermutation.size() == nums.length){
            permuteList.add(new ArrayList<>(currentPermutation));
            return;
        }

        for (int num : nums){
             if (currentPermutation.contains(num)){
                 continue;
             }
            // add element
            currentPermutation.add(num);


            backtrack(nums, currentPermutation);

            //remove element
            currentPermutation.remove(currentPermutation.size() - 1);
        }
    }

    public List<List<Integer>> permute(int[] nums) {
        permuteList.clear();
        backtrack(nums, new ArrayList<>());
        return permuteList;
    }

    public static void main(String[] args) {
        int[] first = {1, 2, 3};
        int[] second = {0,1};
        int[] third = {1};
        Permutations permutations = new Permutations();
        //[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
        System.out.println(permutations.permute(first));
        //[[0,1],[1,0]]
        System.out.println(permutations.permute(second));
        //[[1]]
        System.out.println(permutations.permute(third));
    }
}

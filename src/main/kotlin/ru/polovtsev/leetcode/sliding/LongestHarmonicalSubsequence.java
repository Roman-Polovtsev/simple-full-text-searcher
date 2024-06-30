package ru.polovtsev.leetcode.sliding;

public class LongestHarmonicalSubsequence {


    /*
        1, 3, 2, 2, 5, 2, 3, 7

        input | max | min | res
         1                  0
         3       3     2     0
         3       3     2     0

     */

    public int findLHS(int[] nums) {
        if (nums == null || nums.length == 0) return 0;
//        int max = Integer.MIN_VALUE;
//        int min = Integer.MAX_VALUE;
        int max = 0;
        int min = 0;
        int length = 0;
        for (int i = 0; i < nums.length - 1; i++) {
            int right = i;
            while (right < nums.length ) {
               if (max - min == 1) {
                   max = Math.max(max, nums[right]);
                   min = Math.min(min, nums[right]);
                   right++;
               } else break;
            }
            length = Math.max(length, right-i);
        }
        return max;
    }

    public static void main(String[] args) {
        int res = new LongestHarmonicalSubsequence().findLHS(new int[]{1, 3, 2, 2, 5, 2, 3, 7});
        System.out.println("res = " + res);
    }
}

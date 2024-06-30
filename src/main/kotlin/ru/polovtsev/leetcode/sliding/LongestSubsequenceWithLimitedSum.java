package ru.polovtsev.leetcode.sliding;

import java.util.Arrays;

public class LongestSubsequenceWithLimitedSum {

    public int[] answerQueries(int[] nums, int[] queries) {
        int sum = 0;
        int[] result = new int[queries.length];
        Arrays.sort(nums);

        for (int j = 0; j < queries.length; j++) {
            for (int i = 0; i < nums.length; i++) {
                int right = i;
                sum += nums[i];
                while (sum <= queries[j] && right < nums.length) {
                    sum += nums[right++];
                    right++;
                }
                int res = right - i;
                result[j] = Math.max(result[j], res);
                sum = 0;
            }
        }
        return result;
    }

    public static void main(String[] args) {
        int[] nums1 = {4, 5, 2, 1};
        int[] queries1 = {3, 10, 21};
        System.out.println(Arrays.toString(new LongestSubsequenceWithLimitedSum().answerQueries(nums1, queries1)));

        int[] nums2 = {2,3,4,5};
        int[] queries2 = {1};
        System.out.println(Arrays.toString(new LongestSubsequenceWithLimitedSum().answerQueries(nums2, queries2)));
    }
}

package ru.polovtsev.leetcode;

import java.util.Arrays;

public class ProductOfArrayExceptSelf {

    /*  1, 2, 3, 4
        prefix 1,1*1=1,1*2=2,1*2*3=6,  1,1,2,6
        suffix 2*3*4=24,3*4=12,4,1

        res = prefix[i]*suffix[i]
     */
    public int[] productExceptSelf(int[] nums) {
       int [] prefix = new int[nums.length];
       int [] suffix = new int[nums.length];

       int[] res = new int[nums.length];
       prefix[0] = 1;
       suffix[nums.length-1] = 1;

       //populate prefix
       for (int i = 1; i < nums.length; i++) {
           prefix[i] = prefix[i-1]*nums[i-1];
       }

       //populate suffix
        for (int i = nums.length - 2; i >= 0; i--) {
            suffix[i] = suffix[i+1]*nums[i+1];
        }

        for (int i = 0; i < nums.length; i++) {
            res[i] = prefix[i]*suffix[i];
        }
       return res;
    }

    public static void main(String[] args) {
        int[] first = {1, 2, 3, 4};
        int[] second = {-1, 1, 0, 3, -3};
        System.out.println(Arrays.toString(new ProductOfArrayExceptSelf().productExceptSelf(first)));
        System.out.println(Arrays.toString(new ProductOfArrayExceptSelf().productExceptSelf(second)));
    }
}

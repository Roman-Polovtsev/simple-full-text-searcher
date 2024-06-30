package ru.polovtsev.leetcode.arrays;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FindAllDuplicatesInArray {

    public List<Integer> findDuplicatesAdditionalArray(int[] nums) {
        List<Integer> result = new ArrayList<>();
        Set<Integer> uniqueSet = new HashSet<>();
        for (int num : nums) {
            if (uniqueSet.contains(num)) {
                result.add(num);
            } else {
                uniqueSet.add(num);
            }
        }
        return result;
    }

    /*
    10,2,5,10,9,1,1,4,3,7
    10,2,5,10,9,1,1,4,3,-7
    10,-2,5,10,9,1,1,4,3,-7
    10,-2,5,-10,9,1,1,4,3,-7



     */
    public List<Integer> findDuplicates(int[] nums) {
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i < nums.length; i++) {
            //use value as index for searching
            // nums[i] = 5 -> look for index 5 \
            // if there is a duplicate  value -> we will find the same ceil 2 times
            var index = Math.abs(nums[i]) - 1; //-1 as we got input values in range [1,n]
            int value = nums[index];
            if (value < 0){
                result.add(Math.abs(nums[i]));
            }else {
                // we got here only if number is duplicated
                nums[index] = -value;
            }
        }
        return result;
    }

    public List<Integer> findDuplicatesXor(int[] nums) {
        List<Integer> result = new ArrayList<>();
        int xored = 0;
        for (int i = 1; i <= nums.length; i++) {
            xored^= i;
        }
        for (int i = 0; i < nums.length; i++) {
            xored = xored^nums[i];
        }
        // 010
        // 011
        //  001
        return result;
    }

    public static void main(String[] args) {
//        int[] arr = new int[]{4,3,2,7,8,2,3,1};
        int[] arr5 = new int[]{10,2,5,10,9,1,1,4,3,7};
        int[] arr1 = new int[]{1,1,2};
        int[] arr2 = new int[]{1};
        FindAllDuplicatesInArray duplicates = new FindAllDuplicatesInArray();
        System.out.println("duplicates.findDuplicates(arr) = " + duplicates.findDuplicates(arr5));
        System.out.println("duplicates.findDuplicates(arr1) = " + duplicates.findDuplicates(arr1));
        System.out.println("duplicates.findDuplicates(arr2) = " + duplicates.findDuplicates(arr2));
    }
}

package ru.polovtsev.leetcode.arrays;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class FindAllNumbersDisappearedInArray {

    //ints = {4,3,2,-7,8,2,3,1};
    //ints = {4,3,-2,-7,8,2,3,1};
    //ints = {4,-3,-2,-7,8,2,3,1};
    //ints = {4,-3,-2,-7,8,2,-3,1};
    //ints = {4,-3,-2,-7,8,2,-3,-1};
    //ints = {4,-3,-2,-7,8,2,-3,-1};
    //ints = {4,-3,-2,-7,8,2,-3,-1};
    //ints = {-4,-3,-2,-7,8,2,-3,-1}; - unmarked indexes 4,5 -> result 5,6

    public List<Integer> findDisappearedNumbers(int[] nums) {
        var result = new ArrayList<Integer>();
        //mark all positions with negate value for numbers that are present
        for (int i = 0; i < nums.length; i++) {
            int expectedIndexForNumI = Math.abs(nums[i]) - 1;
            if (nums[expectedIndexForNumI] > 0){
                nums[expectedIndexForNumI] *= -1;
            }
        }

        for (int i=0; i < nums.length; i++){
            if(nums[i] > 0){
                result.add(i+1);
            }
        }
        return result;
    }

    // 1,3,3,2,5,6,8,8,9
    // -1,3,3,2,5,6,8,8,9
    // -1,3,-3,2,5,6,8,8,9
    // -1,3,-3,2,5,6,8,8,9

    public static void main(String[] args) {
        int[] ints = {4,3,2,7,8,2,3,1};
        //ints = {4,3,2,-7,8,2,3,1};
        //ints = {4,3,-2,-7,8,2,3,1};
        //ints = {4,-3,-2,-7,8,2,3,1};
        //ints = {4,-3,-2,-7,8,2,-3,1};
        //ints = {4,-3,-2,-7,8,2,-3,-1};
        //ints = {4,-3,-2,-7,8,2,-3,-1}; //result.add(i) = 5
        //ints = {4,-3,-2,-7,8,2,-3,-1}; //result.add(i) = 6
        //ints = {-4,-3,-2,-7,8,2,-3,-1};

        List<Integer> result = new FindAllNumbersDisappearedInArray().findDisappearedNumbers(ints);
        System.out.println(result);
    }
}

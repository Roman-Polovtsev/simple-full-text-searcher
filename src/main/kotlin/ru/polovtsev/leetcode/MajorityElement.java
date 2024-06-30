package ru.polovtsev.leetcode;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class MajorityElement {
    public int majorityElement(int[] nums) {
        int res = 0;
        int count = 0;

        /*
           1,2,3,2,1,2,2,2
           num |res | count
           1   | 1  | 1
           2   | 1  | 0
           3   | 3  | 1
           2   | 3  | 0
           1   | 1  | 1
           2   | 1  | 0
           2   | 2  | 1
           2   | 2  | 2
         */


        for(int num: nums){
            if(count == 0) {
                //initialize a res
                res = num;
            }
            if (num == res){
                //if next element is same - increase counter
                count++;
            } else {
                count--;
            }
        }
        return res;
    }

    public static void main(String[] args) {
        int[] nums = {2, 1, 2, 1, 4, 5, 2, 1, 1};
        String abc = "abc";
        char c = abc.charAt(1);
        System.out.println(c >= 'a');
        System.out.println(new MajorityElement().majorityElement(nums));
    }
}

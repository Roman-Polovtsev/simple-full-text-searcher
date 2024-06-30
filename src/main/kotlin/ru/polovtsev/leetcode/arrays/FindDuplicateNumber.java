package ru.polovtsev.leetcode.arrays;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FindDuplicateNumber {

    /*slow + fast pointer

   val 1,3,4,2,2
   idx 0,1,2,3,4

   val | idx | slow | fast
    1     0     0      0  - start
    1     0     1      3
    3     1     3      2
    4     2     4      2
    2     3     2      4
    2     4     2      4
*/

    //logic - we want to swap all values in [1,n] to indexes where  nums[idx] = idx,
    // except for nums[0] - there will be duplicate
    /*
        1,3,4,2,2
        3,1,4,2,2
        2,1,4,3,2
        4,1,2,3,2
        2,1,2,3,4
     */
    public int findDuplicateCyclicSort(int[] nums) {
        while (true){
            int value = nums[0];
            if (nums[value] == value){
                return value;
            }
            else {
                int temp = nums[value];
                nums[value] = nums[0];
                nums[0] = temp;
            }
        }
    }


    public int findDuplicate(int[] nums) {
        int slow = 0;
        int fast = 0;

        //find pointers intersection - it could be at any point of cycle
        do {
            slow = nums[slow];
            fast = nums[fast];
            fast = nums[fast];
        } while (fast != slow);

        //add another slow pointer to start from the beginning -
        // there's a fact that they will meet at the searching number
        int newSlow = 0;
        while (slow != newSlow) {
            slow = nums[slow];
            newSlow = nums[newSlow];
        }
        return newSlow;
    }


    public static void main(String[] args) {
        int[] arr5 = new int[]{1,3,4,2,2};
        int[] arr1 = new int[]{3,1,3,4,2};
        int[] arr2 = new int[]{3,3,3,3};
        FindDuplicateNumber duplicates = new FindDuplicateNumber();
        System.out.println("duplicates.findDuplicates(arr) = " + duplicates.findDuplicate(arr5));
        System.out.println("duplicates.findDuplicates(arr1) = " + duplicates.findDuplicate(arr1));
        System.out.println("duplicates.findDuplicates(arr2) = " + duplicates.findDuplicate(arr2));
    }
}

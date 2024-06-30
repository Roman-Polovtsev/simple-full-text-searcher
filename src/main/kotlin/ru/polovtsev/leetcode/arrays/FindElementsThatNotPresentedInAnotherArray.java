package ru.polovtsev.leetcode.arrays;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class FindElementsThatNotPresentedInAnotherArray {

    //both arrays are sorted
    public List<Integer> find(int[] first, int[] second) {
        if (first.length == 0 ) return new ArrayList<>();
        if (second.length == 0) return Arrays.stream(first).boxed().collect(Collectors.toList());
        List<Integer> result = new ArrayList<>();
        int pointer1 = 0;
        int pointer2 = 0;
        for (int i = 0; i < first.length; i++) {
            if (first[pointer1] == second[pointer2]) {
                pointer1++;
                pointer2++;
            } else {
                result.add(first[pointer1]);
                pointer1++;
            }
        }
        return result;
    }

    public static void main(String[] args) {
        FindElementsThatNotPresentedInAnotherArray task = new FindElementsThatNotPresentedInAnotherArray();
        //
        int[] first = {-10, 1, 2, 4, 6, 7, 15};
        int[] second   = { 1, 2, 4, 7, 15};
        List<Integer> result = task.find(first, second);
        System.out.println("result = " + result);
    }
}

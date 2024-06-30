package ru.polovtsev.leetcode

import kotlin.math.max

class MaximumAverageSubarray643 {

    fun findMaxAverage(nums: IntArray, k: Int): Double {
        var currentMax = Double.NEGATIVE_INFINITY
        var sum = 0
        for (i in 0 until k){
            sum += nums[i]
        }
        currentMax = max(currentMax, sum.toDouble()/k)
        for(i in k until nums.size){
            sum = sum + (nums[i] - nums[i-k])
            currentMax = max(currentMax, sum.toDouble()/k)
        }
        return currentMax

    }

    /*
    Example 1:

    Input: nums = [1,12,-5,-6,50,3], k = 4
    Output: 12.75000
    Explanation: Maximum average is (12 - 5 - 6 + 50) / 4 = 51 / 4 = 12.75

    Example 2:

    Input: nums = [5], k = 1
    Output: 5.00000

     */
}

fun main(){
    val a = MaximumAverageSubarray643()
//    a.findMaxAverage(intArrayOf(1,12,-5,-6,50,3), 4)
    a.findMaxAverage(intArrayOf(-1), 1)
}

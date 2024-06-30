package ru.polovtsev.leetcode

import kotlin.math.min


class MinimumSizeSubarraySum209 {

    fun minSubArrayLen(target: Int, nums: IntArray): Int {
        var res = Int.MAX_VALUE
        var sum = nums[0]
        for (i in 1..nums.size-1){
            if (sum >= target){
                res = i+1
            }
            sum += nums[i]
        }
        if (sum < target) return  0
        TODO()
    }

    /*
    Example 1:

    Input: target = 7, nums = [2,3,1,2,4,3]
    Input: target = 7, nums = [1,2,3,4,5]
    Output: 2
    Explanation: The subarray [4,3] has the minimal length under the problem constraint.
    Example 2:

    Input: target = 4, nums = [1,4,4]
    Output: 1
    Example 3:

    Input: target = 11, nums = [1,1,1,1,1,1,1,1]
    Output: 0

     */
}

fun main(){
    val a = MinimumSizeSubarraySum209()
    a.minSubArrayLen(7, intArrayOf(2,3,1,2,4,3))
    a.minSubArrayLen(11, intArrayOf(1,2,3,4,5))
}

package ru.polovtsev.leetcode

class SIngleNumber136 {

    fun singleNumber(nums: IntArray): Int {
        var res = 0
        for (element in nums){
            res = res xor element
        }
        return res
    }
}

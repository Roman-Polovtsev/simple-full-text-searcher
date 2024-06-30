package ru.polovtsev.leetcode

class ContainsDuplicate217 {

    fun containsDuplicate(nums: IntArray): Boolean {
       val map = mutableMapOf<Int, Int>()
        nums.forEach {
            if (map[it] == null)
                map[it] = 1
            else return true
        }
        return false
    }

}

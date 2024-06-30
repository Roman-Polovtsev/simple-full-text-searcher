package ru.polovtsev.leetcode

import kotlin.math.min

class IntersectionOfTwoArrays350 {

    fun intersect(nums1: IntArray, nums2: IntArray): IntArray {
        val set1 = nums1.toList().sorted()
        val set2 = nums2.toList().sorted()
        val resultSet = mutableSetOf<Int>()
        var first = 0
        var second = 0
        while((first < set1.size) && (second < set2.size)){
            if (set1[first] > set2[second]){
                second++
            } else if (set1[first] < set2[second]){
                first++
            } else {
                resultSet.add(set1[first])
                first++
                second++
            }
        }
        return resultSet.toIntArray()
    }
}

fun main(){
    val c = IntersectionOfTwoArrays350()
    val intersect = c.intersect(intArrayOf(4, 9, 5), intArrayOf(9, 4, 9, 4, 8, 4))
    println(intersect)
}

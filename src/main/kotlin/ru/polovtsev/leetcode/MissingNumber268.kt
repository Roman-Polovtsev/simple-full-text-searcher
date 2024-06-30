package ru.polovtsev.leetcode

class MissingNumber268 {

//    fun missingNumber1(nums: IntArray): Int {
//        val size = nums.size
//        var abc = Integer(1)
////        nums.forEachIndexed{  index, i ->
////            if (i xor
////        }
//    }

    fun missingNumber(nums: IntArray): Int {
//        x xor 0 = x
//        x xor x = 0
//        x xor y = x xor y
        val maxValue = nums.size
        var ans = 0;
//       xor all numbers in range from 0 to max value
        for (i in 0..maxValue){
            ans = i xor ans
        }

//        xor previously calculated value with all values from array - all duplicated will kill each other
        for (i in 0 until maxValue)
            ans = nums[i] xor ans
        return ans
    }

}

fun main(){
    val a = MissingNumber268()
    val arr = intArrayOf(1,3,0)
    println(a.missingNumber(arr))
}

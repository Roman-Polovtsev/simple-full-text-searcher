package ru.polovtsev.leetcode

class FindAllNumbersDisappearedInArray448x {

    fun findDisappearedNumbers(nums: IntArray): List<Int> {
        return emptyList()
    }

    fun simpleMap(nums: IntArray): List<Int>{
        val set = nums.toSet()
        val list = mutableListOf<Int>()
        for (i in 1 .. nums.size){
            if (!set.contains(i))
                list.add(i)
        }
        return list
    }
}

fun main() {
    var sum = 0
    for(i in 1..8){
        sum +=  i
    }
    println(sum) //36

}

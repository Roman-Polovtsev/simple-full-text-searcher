package ru.polovtsev.leetcode

import java.util.LinkedList

class ReverseString344 {
    fun reverseString(s: CharArray): Unit {
        val size = s.size - 1
        for (i in 0.. size/2){
            val temp = s[size-i]
            s[size-i] = s[i]
            s[i] = temp
        }
    }
}



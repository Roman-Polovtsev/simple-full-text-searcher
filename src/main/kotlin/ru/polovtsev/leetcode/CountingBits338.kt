package ru.polovtsev.leetcode

class CountingBits338 {
    fun countBits(n: Int): IntArray {
        val arr = IntArray(n + 1)
        arr[0] = 0
        arr[1] = 1
        for (i in 2..n) {
            if (i%2 == 1)
                arr[i] = arr[i-1] + 1
            else arr[i] = arr[i/2]
        }
        return arr
    }

    // 0, 1, 10 = 1, 11  = 2, 100, 101, 110, 111
}

fun main(){
    val c = CountingBits338()
    val bits = c.countBits(5)
    println(bits)
}

/*test cases:
Example 1:

Input: n = 2
Output: [0,1,1]
Explanation:
0 --> 0
1 --> 1
2 --> 10


Example 2:

Input: n = 5
Output: [0,1,1,2,1,2]
Explanation:
0 --> 0
1 --> 1
2 --> 10
3 --> 11
4 --> 100
5 --> 101
6 --> 110
7 --> 111
8 --> 1000
9 --> 1001
10 --> 1010

 */

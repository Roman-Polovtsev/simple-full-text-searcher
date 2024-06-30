package ru.polovtsev.leetcode

class CountingStairs70 {

    fun climbStairs(n: Int): Int {
        val memo = mutableMapOf<Int, Int>()
        return helper(n, memo)
    }

    fun helper(n: Int, memo: MutableMap<Int, Int>): Int{
        if (n == 1 || n == 0)
        return 1
        if (!memo.containsKey(n))
            memo[n] = helper(n-1, memo) + helper(n-2, memo)
        return memo[n]!!
    }
}

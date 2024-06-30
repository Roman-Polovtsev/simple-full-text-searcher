package ru.polovtsev.leetcode

import kotlin.math.max
import kotlin.math.min

class BestTimeToBuyAndSellStock122 {
    fun maxProfit(prices: IntArray): Int {



        var buyPrice = Int.MAX_VALUE
        var sellPrice = 0
        var sellPriceMax = 0
        var sum = 0
        for (i in 1 until prices.size){
            buyPrice = min(buyPrice, prices[i-1])
            sellPrice = max(sellPrice, prices[i] - sellPrice)
            if (sellPrice < sellPriceMax){
                sum += sellPriceMax
                sellPriceMax = 0
                sellPrice = 0
                buyPrice = Int.MAX_VALUE
            }
        }
        return sum
    }


}

fun main(){
    val map = mutableMapOf<Char,Int>()
    var s = "avasva"
    for (i in 0..s.length -1){
        map.compute(s[i]) {
                _, value ->
            value?.plus(1) ?: 1
        }

    }
    map.values.all { it == 0 }
    println(map)
}

/*
Example 1:

Input: prices = [7,1,5,3,6,4]
Output: 7
Explanation: Buy on day 2 (price = 1) and sell on day 3 (price = 5), profit = 5-1 = 4.
Then buy on day 4 (price = 3) and sell on day 5 (price = 6), profit = 6-3 = 3.
Total profit is 4 + 3 = 7.
Example 2:

Input: prices = [1,2,3,4,5]
Output: 4
Explanation: Buy on day 1 (price = 1) and sell on day 5 (price = 5), profit = 5-1 = 4.
Total profit is 4.
Example 3:

Input: prices = [7,6,4,3,1]
Output: 0
Explanation: There is no way to make a positive profit, so we never buy the stock to achieve the maximum profit of 0.
 */

package ru.polovtsev.leetcode

import kotlin.math.max
import kotlin.math.min

class BestTimeToBuyAndSellStock121 {

    /*
    test cases:


    Example 1:

    Input: prices = [7,1,5,3,6,4]
    Output: 5
    Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
    Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.


    Example 2:

    Input: prices = [7,6,4,3,1]
    Output: 0
    Explanation: In this case, no transactions are done and the max profit = 0.
     */

    fun maxProfitCustom(prices: IntArray): Int {
        var max = 0
        var buyDay = 0
        for (i in 0..prices.size){
            while (prices[buyDay] > prices[i])
                buyDay++
            max = max(max, prices[i] - prices[buyDay])
        }
        return max
    }

    fun maxProfitSubArray(){

    }

    fun maxProfit(prices: IntArray): Int {
        var buyPrice = Int.MAX_VALUE
        var sellPrice = 0
        for (i in 1 until prices.size){
            buyPrice = min(buyPrice, prices[i-1])
            sellPrice = max(sellPrice,prices[i]-buyPrice)
        }
        return sellPrice
    }
/*    0,0

 */
}

fun main(){
    val a = BestTimeToBuyAndSellStock121()

    a.maxProfit(intArrayOf(7,1,5,3,6,4))
}

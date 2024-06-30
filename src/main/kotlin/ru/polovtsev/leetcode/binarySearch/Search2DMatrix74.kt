package ru.polovtsev.leetcode.binarySearch

class Search2DMatrix74 {

    fun searchMatrix(matrix: Array<IntArray>, target: Int): Boolean {
        val rowsCount = matrix.size
        val rowArray = matrix[rowsCount-1]
        val columnsSize = rowArray.size
        var targetRowNumber = 0
        for (i in 0 until rowsCount){
            if (target <= matrix[i][columnsSize-1]) {
                targetRowNumber = i
                break
            } else continue
        }

        return binarySearch(matrix[targetRowNumber], target)
    }

    fun searchMatrixOptimal(matrix: Array<IntArray>, target: Int): Boolean{
        val columns = matrix[0].size
        val rows = matrix.size
        var end = rows*columns - 1
        var start = 0

        val array = IntArray(target)
        val arr2 = IntArray(target, )

/*        binary search throughout entire matrix as one-dimensional array

          2d(x*y) to 1d(y) -> 2d[i][j] = 1d[i*y + j]

          1d(y) to 2d -> 1d[i] = 2d[i/y][i%y]

 */
        while (start <= end){
            val pivotIndex = start + (end - start)/2
            val value = matrix[pivotIndex/columns][pivotIndex%columns]
            if (value > target){
                end = pivotIndex - 1
            }
            else if(value  < target){
                start = pivotIndex + 1
            }
            else return true
        }
        return false

    }
//


    private fun binarySearch(arr: IntArray, target: Int): Boolean{
        var rightIndex = arr.size - 1
        var leftIndex = 0
        while (leftIndex <= rightIndex){
            val pivotIndex = (rightIndex + leftIndex)/2
            if (arr[pivotIndex] > target){
                rightIndex = pivotIndex - 1
            }
            else if(arr[pivotIndex] < target){
                leftIndex = pivotIndex + 1
            }
            else return true
        }
        return false
    }
}

fun main(){
    val arr = arrayOf(
        intArrayOf(1, 3, 5, 7),
        intArrayOf(10, 11, 16, 20),
        intArrayOf(23, 30, 34, 60)
    )
    val arr1 = arrayOf(intArrayOf(1))
    val abc = Search2DMatrix74()
    val result = abc.searchMatrixOptimal(arr1, 1)
    println(result)

}

/*
Input: matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3

 1 3 5 7 10 11 16 20 23 30 34 60
Output: true


Input: matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 13
Output: false
 */

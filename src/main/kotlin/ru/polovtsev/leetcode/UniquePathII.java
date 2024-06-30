package ru.polovtsev.leetcode;

public class UniquePathII {
    public int uniquePathsWithObstacles(int[][] obstacleGrid) {
        int rows = obstacleGrid.length;
        int columns = obstacleGrid[0].length;
        int [][] dp = new int[rows][columns];
        for (int i = 0; i < rows; i++){
            if (obstacleGrid[i][0] == 1){
                dp[i][0] = 0;
                break;
            } else dp[i][0] = 1;
        }

        for (int i = 0; i < columns; i++){
            if (obstacleGrid[0][i] == 1){
                dp[0][i] = 0;
                break;
            } else dp[0][i] = 1;
        }

        for (int i = 1; i < rows; i++){
            for (int j = 1; j < columns; j++){
                if(obstacleGrid[i][j] == 1){
                    dp[i][j] = 0;
                } else {
                    dp[i][j] = dp[i][j-1] + dp[i-1][j];
                }
            }
        }


        return dp[rows-1][columns-1];
    }

    public static void main(String[] args) {
        UniquePathII pathII = new UniquePathII();
        pathII.uniquePathsWithObstacles(new int[][]{
            new int[]{0,0,1,0},
            new int[]{0,1,0,0},
            new int[]{0,0,0,0},
        });
    }

}

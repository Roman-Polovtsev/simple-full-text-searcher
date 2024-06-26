package ru.polovtsev.leetcode;

public class UniquePath63 {
    public int uniquePaths(int m, int n) {
        int[][] dp = new int[m][n];
        dp[0][0] = 0;
        for (int i = 0; i < m; i++){
            dp[i][0] = 1;
        }
        for (int i = 0; i < n; i++){
            dp[0][i] = 1;
        }
        int i= 1;
        int j = 1;
        while (i < m) {
            while (j < n) {
                dp[i][j] = dp[i-1][j] + dp[i][j-1];
                j++;
            }
            j = 1;
            i++;
        }
        return dp[m-1][n-1];
    }

    public static void main(String[] args) {
        UniquePath63 path63 = new UniquePath63();
        int i = path63.uniquePaths(3, 7);
        System.out.println(i);
    }
}

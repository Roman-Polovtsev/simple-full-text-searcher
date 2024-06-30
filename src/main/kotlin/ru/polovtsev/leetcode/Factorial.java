package ru.polovtsev.leetcode;

import java.util.Scanner;

public class Factorial {

    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        int[] dp = new int[n+1];
        dp[0] = 1;
        for (int i = 1; i <= n; i++){
            dp[i] = dp[i - 1] * i;
        }
        System.out.println(dp[n]);
    }


}

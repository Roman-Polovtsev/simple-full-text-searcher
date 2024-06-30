package ru.polovtsev.leetcode;

import java.util.ArrayList;
import java.util.Scanner;

import static java.lang.Math.max;

public class BookingTalkingRooms {

    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);
        scanner.useDelimiter("\\n");
        var list = new ArrayList<Pair>();
        System.out.print("Enter quantity: ");
        int quantity = scanner.nextInt();
        int[] ints = { 1, 2 };
        int length = ints.length;

        // reading input to map
        for (int i = 1; i <= quantity; i++) {
            System.out.print("Enter interval: ");
            String line = scanner.next();
            String[] s = line.split(" ");
            list.add(
                new Pair(Integer.parseInt(s[0]), Integer.parseInt(s[1]))
            );
        }

        int[][] dp = new int[quantity][quantity];

//        Integer[] dp = Stream.generate(() -> 1).limit(list.size()).toArray(Integer[]::new);
        int max = 0;
        int sum = 0;
        for (int i = 0; i < quantity; i++){
            for (int j = i + 1; j <quantity; j++) {
                if (list.get(i).right < list.get(j).left){
                    dp[i][j] = 1;
                    dp[j][i] = 1;
                    sum += 1;
                } else {
                    dp[i][j] = 0;
                    dp[j][i] = 0;
                }

            }
            max = max(max,sum);
            sum = 0;
        }
        System.out.println(max);
        //        System.out.println(Arrays.stream(dp).max(Integer::compare).get());
    }

    public static class Pair{
        int left;
        int right;

        public Pair(int left, int right) {
            this.left = left;
            this.right = right;
        }

        public int getLeft() {
            return left;
        }

        public int getRight() {
            return right;
        }

        @Override public String toString() {
            return "Pair{" + "left=" + left + ", right=" + right + '}';
        }
    }


}

/*
3
1 3
2 3
4 5
 */

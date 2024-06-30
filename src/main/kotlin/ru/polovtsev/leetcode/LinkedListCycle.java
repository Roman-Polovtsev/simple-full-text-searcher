package ru.polovtsev.leetcode;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Stack;

public class LinkedListCycle {
    public boolean hasCycle(ListNode head) {
        if (head == null || head.next == null) return false;
        var fast = head.next;
        var slow = head;

        while (fast.next != null && slow.next != null){
            if(fast.val == slow.val){
                return true;
            }
            fast = fast.next.next;
            slow = slow.next;
        }
        HashMap<Integer, Integer> map = new HashMap<>();
        int[] array = new int[]{1,2,3};
        Arrays.sort(array);
        for (int i : array) {
            array[i] = i;
        }
        Stack<Character> stack = new Stack<>();
        Stack<Character> stack1 = new Stack<>();
        stack.push('a');
        stack.pop();
        return false;
    }

    public static void main(String[] args) {
        ListNode node = new ListNode(1, new ListNode(2));
        boolean result = new LinkedListCycle().hasCycle(node);
    }
}

class ListNode {
      int val;
      ListNode next;
      ListNode(int x) {
          val = x;
          next = null;
      }

    public ListNode(int val, ListNode next) {
        this.val = val;
        this.next = next;
    }
}

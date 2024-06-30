package ru.polovtsev.leetcode.binaryTree;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode() {}
 *     TreeNode(int val) { this.val = val; }
 *     TreeNode(int val, TreeNode left, TreeNode right) {
 *         this.val = val;
 *         this.left = left;
 *         this.right = right;
 *     }
 * }
 */


public class InvertBinaryTree {

    public TreeNode invertTree(TreeNode root) {
        var abc = root;
        while(root != null) {
            var left = root.left;
            var right = root.right;
            root = new TreeNode(root.val, invertTree(right), invertTree(left));
        }
        return abc;
    }

    List<Integer> result = new ArrayList<>();
    public List<Integer> inorderTraversal(TreeNode root) {
        helper(root);
        return result;
    }

    private void helper(TreeNode current){
        if(current != null){
            helper(current.left);
            result.add(current.val);
            System.out.println(current.val);
            helper(current.right);
        }
    }

    public static class TreeNode {
      int val;
      TreeNode left;
      TreeNode right;
      TreeNode() {}
      TreeNode(int val) { this.val = val; }
      TreeNode(int val, TreeNode left, TreeNode right) {
          this.val = val;
          this.left = left;
          this.right = right;
      }
    }

    public static void main(String[] args) {
//        TreeNode node = new TreeNode(2, new TreeNode(3), new TreeNode(1));
        InvertBinaryTree invertBinaryTree = new InvertBinaryTree();
//        TreeNode result = invertBinaryTree.invertTree(node);
//        System.out.println("result = " + result);
        TreeNode treeNode = new TreeNode(1, null, new TreeNode(2, new TreeNode(3), null));
        List<Integer> integers = invertBinaryTree.inorderTraversal(treeNode);
        System.out.println(integers);
    }
}

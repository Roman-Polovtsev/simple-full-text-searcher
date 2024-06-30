package ru.polovtsev.leetcode.binaryTree;

import java.util.LinkedList;
import java.util.Queue;

public class MinDepthOfBinaryTree {
    public int minDepth(TreeNode root) {
        if (root == null) return 0;
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(root);
        int depth = 1; //as first node
        while (!queue.isEmpty()){
            int size = queue.size();
            for (int i = size; i > 0; i--) {
                TreeNode current = queue.poll();

                if(current.left == null && current.right == null){
                    return depth;
                }
                if(current.left != null){
                    queue.add(current.left);
                }
                if(current.right != null){
                    queue.add(current.right);
                }

            }
            depth++;

        }
        return depth;
    }

    public int minDepthRecursive(TreeNode root) {
        return 0;
    }




    public static void main(String[] args) {
        //root = [3,9,20,null,null,15,7]
        TreeNode root = new TreeNode(3, new TreeNode(9), new TreeNode(20, new TreeNode(15), new TreeNode(7)));
        int res = new MinDepthOfBinaryTree().minDepth(root);
        System.out.println("res = " + res);
    }
}

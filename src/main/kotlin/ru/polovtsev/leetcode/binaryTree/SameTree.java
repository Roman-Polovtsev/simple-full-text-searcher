package ru.polovtsev.leetcode.binaryTree;

import java.util.LinkedList;
import java.util.Queue;

public class SameTree {
    public boolean isSameTree(TreeNode p, TreeNode q) {
        if (p == null && q == null) return true;
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(p);
        queue.add(q);
        while (!queue.isEmpty()) {
            q = queue.poll();
            p = queue.poll();

            if (p.val != q.val) return false;


        }
        return false;
//        return isSameTree()
    }

    public boolean isSameTreeRec(TreeNode p, TreeNode q) {
        if (p == null && q == null) return true;
        if (p.left == q.left) return isSameTreeRec(p.right, q.right);
        if (p.right == q.right) return isSameTreeRec(p.left, q.left);
        if (p.val != q.val) return false;
//        if (p.right == null && q.right == null && p.left == null && q.left == null)
            return p.val == q.val;
//        if (p.left == null && q.left != null) return false;
//        if (p.left != null && q.left == null) return false;
//        if (p.right == null && q.right != null) return false;
//        if (p.right != null && q.right == null) return false;
//        return isSameTree(p.left, q.left) && isSameTree(p.right, q.right);
    }


    public static void main(String[] args) {
//        p = [1,2,3], q = [1,2,3]
        TreeNode first = new TreeNode(1, new TreeNode(2), new TreeNode(3));
        TreeNode second = new TreeNode(1, new TreeNode(2), new TreeNode(3));
        TreeNode third = new TreeNode(1, new TreeNode(2, new TreeNode(4), null), new TreeNode(3));
        SameTree sameTree = new SameTree();
        System.out.println("sameTree.isSameTree(first, second) = " + sameTree.isSameTreeRec(first, second));
        System.out.println("sameTree.isSameTree(first, third) = " + sameTree.isSameTreeRec(first, third));
    }
}

package ru.polovtsev.leetcode.binaryTree;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class FindAllParents {

    public static class Category{
        Integer parentId;
        Integer id;
        String name;

        public Category(Integer parentId, int id) {
            this.parentId = parentId;
            this.id = id;
        }

        public Integer getParentId() {
            return parentId;
        }

        public Integer getId() {
            return id;
        }

        public String getName() {
            return name;
        }

        @Override
        public String toString() {
            return "Category{" +
                    "parentId=" + parentId +
                    ", id=" + id +
                    ", name='" + name + '\'' +
                    '}';
        }
    }

    Set<Category> getAllParents(List<Category> categoryList, int categoryId){
        Set<Category> result = new HashSet<>();
        Map<Integer,Category> categoryMap = categoryList.stream()
                .collect(Collectors.toMap(Category::getId, Function.identity()));
        Set<Integer> visited = new HashSet<>();
        helper(categoryMap,categoryId,result, visited);
        return result;

    }

    private void helper(Map<Integer, Category> categoryMap, Integer categoryId, Set<Category> result, Set<Integer> visited) {
        Category category = categoryMap.get(categoryId);
        Integer parentId = category.getParentId();
        if (parentId != null && categoryId != null && !visited.contains(categoryId)) {
            result.add(categoryMap.get(parentId));
            visited.add(categoryId);
            helper(categoryMap,parentId,result, visited);
        }
    }


    public static void main(String[] args) {
        List<Category> categoryList = List.of(
                new Category(null, 1),
                new Category(2, 3),
                new Category(3, 4),
                new Category(3, 2),
                new Category(4, 5));
        Set<Category> result = new FindAllParents().getAllParents(categoryList, 3);
        System.out.println("result = " + result);
    }
}

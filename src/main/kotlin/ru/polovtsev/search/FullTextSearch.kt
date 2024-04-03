package ru.polovtsev.search

interface FullTextSearch {

    fun search(word: String ): List<String>

    fun count(word: String, searchableData: List<String>): Map<String, Int>
}
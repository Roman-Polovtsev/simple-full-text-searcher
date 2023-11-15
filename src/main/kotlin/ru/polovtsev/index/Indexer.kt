package ru.polovtsev.index

interface Indexer {

    fun index(rawData: List<String>) : MutableMap<String, MutableSet<Int>>
}
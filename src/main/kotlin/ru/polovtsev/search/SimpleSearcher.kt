package ru.polovtsev.search

import ru.polovtsev.index.Indexer
import java.util.Collections.unmodifiableList

class SimpleSearcher(private var indexedData: List<String> =  mutableListOf()) : FullTextSearch, Indexer {


    override fun index(rawData: List<String>): MutableMap<String, MutableSet<Int>> {
        indexedData = rawData
        return rawData.asSequence().map { it to mutableSetOf<Int>() }.toMap().toMutableMap()
    }

    override fun search(word: String ): List<String> {
        val mutable = indexedData.asSequence()
            .filter { it.contains(word, true) }
            .toCollection(mutableListOf())
        return unmodifiableList(mutable)
    }

    override fun count(word: String, searchableData: List<String>): Map<String, Int> {
        return searchableData.asSequence()
            .map { inStringSearching(it,word) }
            .filter { it.second != 0 }
            .toMap()
    }

    private fun inStringSearching(line: String, word: String): Pair<String, Int> {
        var position = 0;
        var count = 0
         while (true) {
            position = line.indexOf(word, position,true)
            if (position >= 0) {
                count++
            }
            else {
                break
            }
            position++
        }
        return line to count
    }



}
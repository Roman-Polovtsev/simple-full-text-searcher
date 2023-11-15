package ru.polovtsev.search

import java.util.Collections.unmodifiableList

class SimpleSearcher : FullTextSearch {

    override fun search(word: String, searchableData: List<String>): List<String> {
        val mutable = searchableData.asSequence()
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
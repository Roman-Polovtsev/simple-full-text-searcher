package ru.polovtsev.search

import ru.polovtsev.index.DefaultSplitter
import ru.polovtsev.index.Indexer
import ru.polovtsev.index.Splitter

class InvertedIndexSearcher(private val splitter: Splitter = DefaultSplitter(),
                            private val index: MutableMap<String, MutableSet<Int>> = mutableMapOf(),
                            val sourceData: MutableList<String> = mutableListOf()) : FullTextSearch, Indexer {

    override fun index(rawData: List<String>) :  MutableMap<String, MutableSet<Int>> {
        sourceData.addAll(0, rawData)
        rawData.asSequence().forEachIndexed { index, value ->
             populateIndex(index + 1, splitter.split(value).keys.toList())
        }
        return index
    }

    private fun populateIndex(idx: Int, splitted: List<String>) =
        splitted.map { it.lowercase() }.forEach {
            if(!index.containsKey(it))
                index[it] = mutableSetOf(idx)
            else {
                val res = index[it]
                res!!.add(idx)
            }
        }

    override fun search(word: String ): List<String> {
        val docs = index[word.lowercase()] ?: return listOf()
        return docs.asSequence().map { sourceData[it-1] }.toCollection(mutableListOf())
    }

    override fun count(word: String, searchableData: List<String>): Map<String, Int> {
        TODO("Not yet implemented")
    }
}
package ru.polovtsev.search

import ru.polovtsev.index.DefaultSplitter
import ru.polovtsev.index.Indexer
import ru.polovtsev.index.PositionedInvertedIndex
import ru.polovtsev.index.Splitter

class PositionedIndexSearcher (private val splitter: Splitter = DefaultSplitter(),
                               private val index: PositionedInvertedIndex = PositionedInvertedIndex(),
                               val sourceData: MutableList<String> = mutableListOf()) : FullTextSearch, Indexer {



    override fun search(word: String, searchableData: List<String>): List<String> {
        TODO("Not yet implemented")
    }

    override fun count(word: String, searchableData: List<String>): Map<String, Int> {
        TODO("Not yet implemented")
    }

    override fun index(rawData: List<String>): MutableMap<String, MutableSet<Int>> {
        var indexed = rawData
        val tokens = indexed.flatMap { splitter.split(it) }.toCollection(mutableListOf())

        rawData.asSequence().forEachIndexed {
            ind, value -> {
                val tokens = splitter.split(value)
                tokens.forEach {
                    if (index.notContains(it)){

                    } else {

                    }
                }
            }
        }

//        for (lines,: String in indexed) {
//            if (index.notContains())
//                index.populate(ind,)
//        }

        tokens.asSequence().forEachIndexed {
            ind, value -> {
                if (index.notContains(ind))
                    index.populateNew(ind)
            }
        }
    }

}
package ru.polovtsev.search

import ru.polovtsev.index.*

typealias TokenFilter = (String) -> String

class PositionedIndexSearcher (private val splitter: Splitter = DefaultSplitter(),
                               val index: PositionedInvertedIndex = PositionedInvertedIndex(),
                               val sourceData: MutableList<String> = mutableListOf(),
                               private val tokenFilter: TokenFilter = StandardTokenFilter()) : FullTextSearch, Indexer {

    override fun search(word: String ): List<String> {

        TODO("Not yet implemented")
    }

    override fun count(word: String, searchableData: List<String>): Map<String, Int> {
        TODO("Not yet implemented")
    }

    override fun index(rawData: List<String>): MutableMap<String, MutableSet<Int>> {
        val data = rawData
        val tokensWithPositionsList = data.map { splitter.split(it) }.toCollection(mutableListOf()) // [["a":2..3, "b": 5..6, "a":7..10],["b": 6..9]]
        tokensWithPositionsList.forEachIndexed { ind, value -> value.forEach{ index.populate(tokenPreparement(it.key), ind, it.value) } }
        return mutableMapOf()
    }

    private fun tokenPreparement(token : String) : String = tokenFilter.invoke(token)

    internal class StandardTokenFilter: TokenFilter{

        override fun invoke(token: String): String = token.lowercase()

    }
}


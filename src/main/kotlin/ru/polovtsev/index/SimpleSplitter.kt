package ru.polovtsev.index

class SimpleSplitter : Splitter {

    companion object {
        private const val DELIMITER = " "
    }

    override fun split(raw: String): MutableMap<String, TokenPosition> {
        return raw.split(DELIMITER).associateWith { TokenPosition.empty() }.toMutableMap()
    }


}
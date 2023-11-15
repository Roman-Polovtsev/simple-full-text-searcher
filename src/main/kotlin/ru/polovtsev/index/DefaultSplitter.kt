package ru.polovtsev.index



class DefaultSplitter : Splitter {

    override fun split(raw: String): MutableMap<String, TokenPosition> {
       return indexAlgorithm(mutableMapOf(), raw)
            { start, end, source, destination -> destination[token(start, end, source)] = TokenPosition(start, end) }
    }

    override fun splitWithoutPosition(raw: String): List<String> {
       return indexAlgorithm(mutableListOf(), raw)
       { start, end, source, destination -> destination.add(token(start, end, source)) }
    }

    private fun <T> indexAlgorithm(destination: T, raw: String, action: (Int, Int, String, T) -> Unit): T {
        var start = -1;
        val chars = raw.toCharArray()
        for (item in raw.indices)
        {
            if (chars[item].isLetterOrDigit()){
                start = setStartPosition(start, item)
            } else {
                if (start >= 0) {
                    action.invoke(start, item, raw, destination)
                    start = -1
                }
            }
        }
        return destination
    }

    private fun setStartPosition(currentStart: Int, item: Int): Int {
        var start = currentStart
        if (start == -1)
            start = item
        return start
    }

    private fun token(start: Int, end: Int, raw: String) = raw.substring(start, end)
}
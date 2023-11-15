package ru.polovtsev.index

class PositionedInvertedIndex(val index: MutableMap<String, PositionedDocument> = mutableMapOf()) {

    fun populate(token: String, docId: Int, position: TokenPosition){
        if (!index.containsKey(token))
            index.put(token, PositionedDocument(mutableMapOf(Pair(docId, mutableListOf(position.start)))))
        else {
            val positionedDocument = index[token]!!
            if(!positionedDocument.containsDoc(docId)){
                positionedDocument.addNewDoc(docId, position.start)
            } else
                positionedDocument.populate(docId, position.start)
        }
    }

    override fun toString(): String {
        return "PositionedInvertedIndex(index=$index)"
    }


    class PositionedDocument(private val docPositionMap: MutableMap<Int, MutableList<Int>> = mutableMapOf()){

        fun populate(docId: Int, position: Int){
            docPositionMap[docId]!!.add(position)
        }



        fun containsDoc(docId: Int): Boolean {
            return docPositionMap.containsKey(docId)
        }

        fun positionsForDoc(docId: Int): MutableList<Int> = docPositionMap[docId] ?: mutableListOf()

        fun addNewDoc(docId: Int, start: Int) {
            docPositionMap[docId] = mutableListOf(start)
        }

        override fun toString(): String {
            return "PositionedDocument(docPositionMap=$docPositionMap)"
        }


    }

}
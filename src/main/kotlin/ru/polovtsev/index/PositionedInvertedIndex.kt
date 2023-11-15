package ru.polovtsev.index

class PositionedInvertedIndex(val index: MutableMap<String, PositionedDocument> = mutableMapOf()) {

    fun populate(docId: Int, occurencesList: MutableList<Int>){

    }

    fun populateNew(docId: Int, raw: String){
        index[docId] =
    }

    fun positionsForDoc(docId: Int): MutableList<Int> {
        return docPositionMap[docId] ?: mutableListOf()
    }



    class PositionedDocument(private val docPositionMap: MutableMap<Int, MutableList<Int>> = mutableMapOf()){

        fun populate(docId: Int, occurrenceList: MutableList<Int>){
            docPositionMap[docId] = occurrenceList
        }

        fun positionsForDoc(docId: Int): MutableList<Int> = docPositionMap[docId] ?: mutableListOf()


    }

}
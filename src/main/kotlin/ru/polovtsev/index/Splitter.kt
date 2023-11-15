package ru.polovtsev.index

interface Splitter {

    fun split(raw: String) : MutableMap<String, TokenPosition>

    fun splitWithoutPosition(raw: String): List<String>
}
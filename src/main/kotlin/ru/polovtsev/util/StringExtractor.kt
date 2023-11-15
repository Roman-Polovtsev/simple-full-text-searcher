package ru.polovtsev.util

import java.io.File

class StringExtractor {

    companion object {
        fun readArticleSet(fileName: String) : List<String> = File(fileName).readLines()
    }
}
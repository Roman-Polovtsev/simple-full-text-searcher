package ru.polovtsev.index

data class TokenPosition(val start: Int, val end: Int){

    companion object {
        fun empty() = TokenPosition(0, 0)
    }
}

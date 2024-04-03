package ru.polovtsev.sequence


fun main(){

    val sequence = sequence {
        yield("a")

        val obj = object : Iterable<String> {
        override fun iterator(): Iterator<String> {
            TODO("Not yet implemented")
        }

    }
        val nextFunction: (String) -> String = {
            if (!it.endsWith("c")) {
                it.plus(it.last().plus(2))
            } else it.plus(1)
        }
        yieldAll(generateSequence("a", nextFunction))
    }
    println(sequence.takeWhile { it.length < 10 }.toList())

    Cat.meow()
    Dog.bark()
}

class Dog{

    companion object{  // equals to static final class in Java
        init {
            println("companion dog initiated")
        }

        fun bark(){
            println("auf")
        }
    }
}

object Cat{

    val name = "kiss"

    fun meow(){
        println("meoow")
    }
}

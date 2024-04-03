package ru.polovtsev.objects

fun main(){

//    object as singletone
    val firstManul = Manul
    val secondtManul = Manul

    println(firstManul == secondtManul)
    println(firstManul === secondtManul)

//    object as implementation of anonymous class
    val printer = AnimalPrinter()

    printer.print()
    Thread.sleep(100)
    printer.print()

    printer.printSingleton()
    Thread.sleep(100)
    printer.printSingleton()

}


class Cat : Animal{

    override fun makeSound(){
        Manul.makeSound()
    }
}


object Manul : Animal {
    override fun makeSound() {
        println("meow")
    }

    override fun toString(): String {
        return hashCode().toString()
    }
}

interface Animal{

    fun makeSound()
}

class AnimalPrinter {


    fun print(){
        println(object {
            override fun toString(): String {
                return hashCode().toString()
            }
        })
    }

    fun printSingleton(){
        println(Manul)
    }
}

class Dog {

    val soundPrinter = object : Animal {
        override fun makeSound() {
            println(hashCode())
        }
    }

    fun bark(){
        println("woopf")
    }
}
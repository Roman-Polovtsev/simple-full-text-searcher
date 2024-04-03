package ru.polovtsev.generics

fun main() {
    val parent = Parent<String>()
    val child = Child()

    println(parent.javaClass.declaredMethods.size)
    println(child.javaClass.declaredMethods.size) // 2: bridge = obj + int

    println(parent.javaClass.declaredMethods[0].parameterTypes[0]) // obj
    println(child.javaClass.declaredMethods[0].parameterTypes[0]) // int -
    println(child.javaClass.declaredMethods[1].parameterTypes[0]) // obj - bridge

    println(child.javaClass.declaredMethods.forEach {
        println("is birdge: " + it.isBridge + " " + it.parameterTypes[0])
    })

}

open class Parent<T> {
    open fun print(t: T){
        println("parent")
    }
}

class Child: Parent<Int>() {
    override fun print(t: Int) {
        println("child")
    }
}
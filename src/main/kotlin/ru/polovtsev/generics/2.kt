package ru.polovtsev.generics

fun main(args: Array<String>){

}

open class A{ open fun x(): Any? = "x"}

class Astr: A(){
    override fun x(): String {
        return "super.x()"
    }
}

class Aint: A(){
    override fun x(): Int {
        return 5
    }
}


//covariance: можем заменить возвращаемое значение на сабкласс (если можем возвращать суперкласс, значит можем и сабкласс),
// при этом Т доступно только на чтение, писать в него нельзя
class Agen<out T>: A(){
    override fun x(): T {
        return TODO()
    }
}

//контравариантность - достигается параметром in - например если метод умеет обращатсья со строками, то он должен уметь
// воспринимать их как объекты и обращаться с ними соответствующе - такой вариант работает на запись

//open class B{ open fun x(a: String ): Any? = "x"}
//
//class Bgen<in T>: B(){
//    override fun x(a: T): Any? {
//        return
//    }
//}
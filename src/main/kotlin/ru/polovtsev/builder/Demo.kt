package ru.polovtsev.builder


@DslMarker
annotation class DemoDsl

@DemoDsl
class Demo {
    var size: Int? = null
    var name: String? = null
    var innerDemo: InnerDemo? = null

    fun init(builder: Demo.()-> Unit): Unit = builder.invoke(this);
    override fun toString(): String {
        return "Demo(size=$size, name=$name, innerDemo=$innerDemo)"
    }


}

@DemoDsl
data class InnerDemo(var size: Int? = null){

    fun abc(){
        size = 10
    }
    fun cde(){
        println("dsaasfsa")
    }
}



fun buildDemo(builder: Demo.() -> Unit): Demo {
    val demo = Demo()
    builder(demo)
    return demo
}

fun innerDemo(innerBuilder: InnerDemo.()->Unit): InnerDemo {
    val innerDemo = InnerDemo()
    innerBuilder(innerDemo)
    return innerDemo

}

fun addSize(obj: Demo): Demo.() -> Unit = {obj.size = 10}

val initDemo = fun(x: Demo, func: Demo.()-> Unit) : Unit = x.init(func)



fun main() {
    val demo1 = buildDemo {
        innerDemo {
            abc()
        }
        innerDemo{
            cde()
        }
    }

    val demo = Demo()
    println(demo)
    println(demo1)
}
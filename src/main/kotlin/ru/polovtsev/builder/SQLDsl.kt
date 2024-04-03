package ru.polovtsev.builder

import java.util.concurrent.locks.Condition
import kotlin.jvm.functions.FunctionN

@DslMarker
annotation class SqlDsl

data class Param(var abc: Int? = null)

fun buildParam(int: Int): Param {
    val param = Param()
    param.abc = int
    return param
}
fun param(param: Param, builder: (Param)-> Unit): Param{
    builder(param)
    return param
}

fun Param.builds(builder: ()-> Unit): Param{
    builder()
    return this
}


 fun Param.build(builder: ()-> Unit): Param {
    builder()
    return this
}

//fun buildz()
//
//fun query(block: Query.()-> Unit): Query  {
//    val query = Query()
//    query.hz {  }
//    query.select = select
//}


data class Query(var select: Select? = null)

@SqlDsl
fun select(block: Select.()-> Unit): Select{
    val select = Select()
    block(select)
    return select
}

@SqlDsl
fun from(block: From.() -> Unit): From? {
    val from = From()
//        .apply(block)
//    select.from = from
//    return from
    block(from)
    return from
}

@SqlDsl
fun where(block: Where.() -> Unit): Where = Where().apply(block)



data class Select(var from: From? = null, var where : Where? = null)

data class From(private var fields: MutableList<String> = mutableListOf()){

    fun fields(vararg vals: String) {
        vals.forEach { fields.add(it) }
    }
}

fun Where.condition(test: Int){
    println("$test  $this")
}
data class Where(var condition: Function<String> = object : Function<String> {

    operator fun invoke(){
        println("invoking $this")
    }
})

fun main(){

//    val s =

    val query = select {
        val from = from {
            fields("salut", "hello")
        }
        println(from)
        where {
            condition(123)
        }
    }

    println(query)
}
package ru.polovtsev.coroutines

import kotlinx.coroutines.*
import kotlin.random.Random
import kotlin.random.nextInt

class Test {


    fun main() = runBlocking{
        repeat(100){
            doWork(it.toString())
        }
    }


}

class Blocking{

    fun main(){
        runBlocking {
            println("start")
            for (i in 0..10) {
                launch {
                    exec(i)
                }
            }
            println("finish")
        }
    }

    suspend fun exec(i: Int){
        println("start do $i")
//        Thread.sleep(Random.nextInt(500).toLong())
        val delay = Random.nextInt(500).toLong()
        delay(delay)
        println("finsh do $i delay was $delay")
    }
}

fun main() = Blocking().main();

//fun main(): Unit = runBlocking(block = repeater2())

private fun repeater1(): suspend CoroutineScope.() -> Unit = {
    val deferredList = List(100) {
        async (start = CoroutineStart.DEFAULT){
            if (isActive)
            doWork(it.toString())
        }
    }
    deferredList.forEach { println(it.cancel()) }

}

private fun repeater2(): suspend CoroutineScope.() -> Unit = {
    val deferredList = List(100) {
        launch {
            if (isActive)
                doWork(it.toString())
        }
    }
    deferredList.forEach { println(it.cancel()) }

}

private fun repeater(): suspend CoroutineScope.() -> Unit = {
    repeat(100) {
        launch {
            doWork(it.toString())
        }
    }
}

suspend fun doWork(name: String): String {
    delay(Random.nextInt(5000).toLong())
    return "Done $name"
}
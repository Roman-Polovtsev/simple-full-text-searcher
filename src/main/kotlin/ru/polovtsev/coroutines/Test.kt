package ru.polovtsev.coroutines

import kotlinx.coroutines.*
import java.time.LocalDateTime
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
            println("start ${LocalDateTime.now()}")
            for (i in 0..10) {
                launch {
                    exec(i)
                }
            }
            println("finish ")
        }
    }

    suspend fun exec(i: Int){
        println("start do $i ")
//        val delay = Random.nextInt(500).toLong()
        val delay1 = 200L
        Thread.sleep(delay1)
//        delay(delay1)
//        println("finsh do $i delay was $delay")
        println("finish  do $i ${LocalDateTime.now()}")
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

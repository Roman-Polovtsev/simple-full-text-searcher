package ru.polovtsev.coroutines

import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext


fun main(){

    val result = runBlocking {
        val async = async {
            delay(500)
            println("async $this")
            50
        }

        launch {
            delay(100)
            println("from launch $this")
        }

        CustomScope().launch {
            delay(100)
            println("launch from custom scope: $this")
        }
        async

        launch {
            val await = async.await()
            println(await)
        }
    }

    CustomScope().launch {
        delay(100)
        println("im here custom $this")
    }

    GlobalScope.launch {
        delay(100)
        println("im here global $this")
    }

    println("result: $result")

}


class CustomScope : CoroutineScope {
    override val coroutineContext: CoroutineContext = CoroutineName("my-custom-coroutine") + EmptyCoroutineContext
}
package ru.polovtsev.coroutines

import kotlinx.coroutines.*
import java.util.concurrent.Executors
import kotlin.coroutines.coroutineContext


private val executor = Executors.newSingleThreadExecutor()
private val dispatcher = executor.asCoroutineDispatcher()

suspend fun doSuspendedThingWithResult(): Int{
    delay(500)
    println("B: ${coroutineContext[Job]}")
    return 4
}

suspend fun doASuspendedThing(label: String ="A"){
    delay(500)
    println("$label: ${coroutineContext[Job]}")
}

suspend fun main(){
    coroutineScope {
        //sequential order
        launch {
            doSuspendedThingWithResult()
//        do athing and do a next thing when the result is there without blocking
            doASuspendedThing()
        }

//    parallel coroutines
        launch(Dispatchers.Default) {

            val job3 = kotlin.coroutines.coroutineContext[Job]
            val job1 = launch {
                doASuspendedThing()
            }

            val job2 = launch {
                doASuspendedThing()
            }
            job1.join()
            job2.join()
        }
    }


//    cancellation
    coroutineScope {
        //sequential order
        val firstJob = launch {
//        do athing and do a next thing when the result is there without blocking
            doASuspendedThing("finished first")
            delay(100)
            doASuspendedThing("finised second")
        }

//    parallel coroutines
        launch(dispatcher) {

            val job1 = launch {
                doASuspendedThing()
                println(ensureActive())
                firstJob.cancel()
            }

            val job2 = launch {
                delay(20)
                doASuspendedThing("Latest")
            }
        }
    }

    executor.shutdown()
}

//отмена корутины физичесски произойдет только в suspension точках - а не в произвольном месте где мы хотим,
// если хотим в произвольном - надо вызывать ensureActive()

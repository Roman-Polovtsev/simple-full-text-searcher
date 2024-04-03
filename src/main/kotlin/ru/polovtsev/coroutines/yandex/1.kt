package ru.polovtsev.coroutines.yandex

import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

suspend fun main(){
//   uniteContexts()
//    childCoroutine()
//    cancelJob()
//    cooperativeCancellation()
//    supervisordoesnotwork()
//    supervisortwork()
//    runCatching()
//    exceptionHamdler()
//    `100_times_counter`()
    channelDemo()
}

//overwriting context elements when uniting coroutins
private suspend fun  uniteContexts(){
    coroutineScope {
        val coroutineContext1 = CoroutineName("First") + Job()
        val coroutineContext2 = coroutineContext1 + CoroutineName("Second")

        println(coroutineContext2[CoroutineName]?.name)
        println(coroutineContext2[Job]?.isActive)
    }
}

// child coroutine has its own job, which is child job for parent coroutine
private suspend fun childCoroutine(){
    coroutineScope {
        val job = Job()
        val coroutineName = CoroutineName("First")
        val coroutineContext1 = coroutineName + job
        launch(coroutineContext1) {
            println(coroutineContext[Job]!= job)
            println(coroutineContext[CoroutineName] == coroutineName)
            println(job.children.first() == job)
        }.join()
    }
}

private suspend fun cancelJob(){
    coroutineScope {
        val job = launch {
            repeat(10) { i ->
                delay(100)
                println("index $i")
            }
        }
        delay(403)
        job.cancelAndJoin()
        println("Cancelled")
    }
}

// cancel child job
suspend fun cooperativeCancellation(){
    coroutineScope {
        val job = launch {
            repeat(100000){
                ensureActive()
                println(it)
            }
        }
        delay(100)
        job.cancel()
    }
}

//canceling job - supervisor job passed as param will not fix the problem, because common parent for job1, job2
// is a child for job - it's not the same SuperivsorJob that in params
suspend fun supervisordoesnotwork(){
    coroutineScope {
        val job = launch(SupervisorJob()) {
            val job1 = launch {
                delay(100)
                throw RuntimeException()
            }
            val job2 = launch {
                delay(200)
                println("never print this")
            }
        }
    }
}

//supervisor scope creates common parent that has supervisor job under the hood
suspend fun supervisortwork(){
    coroutineScope {
        supervisorScope {
            val job1 = launch {
                delay(100)
                throw RuntimeException()
            }
            val job2 = launch {
                delay(200)
                println("printed")
            }
        }
    }
}

suspend fun trycatch(){
    coroutineScope {
        launch {
            try {
                delay(100)
                throw RuntimeException()
            } catch (e:Exception) {
                    println(e)
                }
        }
    }
}

suspend fun runCatching(){
    coroutineScope {
        launch {
            val result : Result<Unit> = runCatching {
                delay(100)
                throw RuntimeException()
            }
            println(result)
        }
    }
}

//custom exceptiom handler -by default all exceptions caulght by UncaughtExceptionHandler
suspend fun exceptionHamdler(){
    coroutineScope {
        val handler = CoroutineExceptionHandler { _, e ->
            println("Exception $e caught!")
        }
        val scope = CoroutineScope(SupervisorJob() + handler)
        scope.launch {
            delay(100)
            throw RuntimeException("Exception!")
        }

        scope.launch {
            delay(200)
            println("result")
        }
        delay(300)
    }
}

//---------SHARED STATE-------------------

//mutex

val mutex = Mutex()
var counter = 0;


//this will sync all actions with counter
suspend fun mutexSync(){
    mutex.withLock {
        counter++
    }
}

suspend fun `100_times_counter`(){
    withContext(Dispatchers.Default) {
        repeat(100) {
            launch {
                repeat(10000) {
                    counter++
//                    mutexSync()
                }
            }
        }
        delay(2000)
        println(counter)
    }

}


//channel - hot data source

suspend fun channelDemo(){

    coroutineScope {
        val channel = Channel<Int>()

        launch {
            repeat(10){
                println("sending $it")
                channel.send(it)
            }
            channel.close()
        }

        launch {
            channel.iterator()
            for (message in channel) {
                val result = channel.receive()
                println("get message: $result")
            }
        }
    }


}

//flow - cold producer
fun studentsFlow() = flow {
    repeat(5){
        delay(100)
        emit("student#$it")
    }
}

suspend fun flowDemo(){
    flow { emit("dbc") }  //flow builder
//            intermideate operations
        .onEach { println(it) }
        .onStart { println("start") }
        .onCompletion { println("completed") }
        .catch { emit("error") }
        // terminal operation - starts flow
        .collect { println("collected") }
}

//shared flow - hot emitter for sharing data
suspend fun sharedFlowDemo(){
    coroutineScope {
//        val flow = MutableSharedFlow<String>()
//
//        launch { flow.collect{ println("1 received $it")} }
//        launch { flow.collect{println("2 received $it")} }
//
//        delay(1000)
//
//        flow.emit("a")
//        flow.emit("b")
    }

}

// always have only current element in buffer
suspend fun stateFlowDemo(){
    coroutineScope {
        val flow = MutableStateFlow("A")

        launch { flow.collect{ println("collect $it")} }

        delay(1000)
//        flow.update{ "B"} - atomically update value in buffer
        flow.value = "B"

        delay(1000)
        launch { flow.collect{ println("second collect $it")} }
    }

}
package ru.polovtsev.builder

fun json(builder: JsonBuilder.() -> Unit): Json = JsonBuilder().apply(builder).json

fun jsonArray(builder: JsonArrayBuilder.() -> Unit): JsonArray = JsonArrayBuilder().apply(builder).array

data class JsonArray(var array: Array<Any?> = emptyArray()): Json(){
    override fun toString(): String {
       return array.joinToString(",","[","]")
    }
}

data class StringType1(var string: String): Json() {

    override fun toString(): String {
        return string
    }
}

fun String.asJsonType() = StringType1(this)


class JsonArrayBuilder(var array: JsonArray = JsonArray()){

}


class JsonBuilder(var json: Json = Json()){

    var str: String? = null

    infix fun String.to(obj: Json){
        json.elements[this] = obj
    }

    infix fun String.to(string: String){
        json.elements[this] = string.asJsonType()
    }

    infix fun String.to(array: JsonArray){
//        json.elements[this] = JsonArray(array)
    }

}


open class Json(var elements: MutableMap<String, Json> = mutableMapOf()){

    override fun toString(): String {
        return elements.entries.joinToString(",", "{", "}")
            {StringBuilder().append(it.key).append(":").append(it.value).toString()}
    }
}

fun main(){
    val json = json {
        str = "safsaf"
        "hello" to json {
            "abc" to "def"
            "values" to jsonArray {  }
        }
    }
    println(json.toString())

    "planning" meeting {
        starts at 3..15
    }
}



class Meeting(val name: String){
    val starts = this

    infix fun at(time: IntRange){
        println("$name starts at $time")
    }
}

infix fun String.meeting(block: Meeting.()->Unit){
     Meeting(this).block()
}

package ru.polovtsev.generics

fun main(){
  val arr = arrayOf(1)
    fill(2, arr)

    assert( arr[0]==2 )
}

fun <T> fill(value: T, arr: Array<T>){
    arr[0]= value
}
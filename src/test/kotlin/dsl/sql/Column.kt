package dsl.sql

class Column(
    val name: String,
    val type: String,
    val default: String?,
    val nullable: Boolean) {
}
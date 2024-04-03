package dsl.sql

class Table(val schema: String, val name: String, val columns: List<Column>, val constraints: List<Constraint>) {
}
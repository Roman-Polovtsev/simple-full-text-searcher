package dsl.sql

interface Constraint {

    class PrimaryKey(val column: Column): Constraint
}
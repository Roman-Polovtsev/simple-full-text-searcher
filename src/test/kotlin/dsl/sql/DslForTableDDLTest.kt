package dsl.sql

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.nulls.shouldBeNull
import io.kotest.matchers.shouldBe
import io.kotest.matchers.types.shouldBeInstanceOf
import io.kotest.matchers.types.shouldNotBeInstanceOf

class DslForTableDDLTest : StringSpec() {

    fun generateWithDsl(): Table{
        val myshema__table by table {
            val id by bigint NOT NULL // bigint.NOT(NULL).DEFAULT('noname')
            val name by text NOT NULL DEFAULT "'noname'"
            val year by int  NOT NULL
            PRIMARY KEY id // this.PRIMARY.KEY(id)
            val valid_year by CHECK("year is null OR > (year > 1950 AND year <= 2030)")
        }
        return  myshema__table
    }

    init {

        "DSL генерация таблицы"{
            generateWithDsl()
        }

        "DSL creates constraint Primary_key"{
            generateWithDsl().constraints[0].run {
                this.shouldBeInstanceOf<Constraint.PrimaryKey>()
                this.column.name shouldBe "id"
            }
        }

        "Columns are of right types"{
            generateWithDsl().run{
                columns[0].run {
                    name shouldBe "id"
                    type shouldBe "bigint"
                    nullable shouldBe false
                    default.shouldBeNull()
                }

                columns[0].run {
                    name shouldBe "name"
                    type shouldBe "text"
                    nullable shouldBe false
                    default shouldBe "'noname'"
                }

                columns[0].run {
                    name shouldBe "year"
                    type shouldBe "int"
                    nullable shouldBe true
                    default.shouldBeNull()
                }
            }
        }

    }
}
package dsl.sql

import kotlin.properties.ReadOnlyProperty
import kotlin.reflect.KProperty



class TableBuilder internal constructor(){
    var schema: String = ""
    var name: String = ""
    var columns: MutableList<ColumnBuilder> = mutableListOf()
    var constraints : MutableList<Constraint> = mutableListOf()

    object __NULL
    val NULL = __NULL

    object __PRIMARY
    val PRIMARY = __PRIMARY

    infix fun __PRIMARY.KEY(column: Column): TableBuilder{
        this@TableBuilder.constraints.add(Constraint.PrimaryKey(column))
        return this@TableBuilder
    }




    inner class ColumnBuilder(
        var name: String = "",
        var type: String = "",
        var default: String? = null,
        var nullable: Boolean = true
    ){


        infix fun DEFAULT(value: String?): ColumnBuilder{
            default = value
            return this
        }

        infix fun NOT(nul: __NULL): ColumnBuilder{
            nullable = false
            return this
        }

        fun build(): Column {
            return Column(
                name = name,
                type = type,
                default = default,
                nullable = nullable
            )
        }

        operator fun provideDelegate(thisRef: Nothing?, property: KProperty<*>): ReadOnlyProperty<Nothing?, Column> {
            name = property.name
            this@TableBuilder.columns.add(this)
            return ReadOnlyProperty { _,_ ->
                this@ColumnBuilder.build()
            }
        }
    }



    val bigint get() = ColumnBuilder(type = "bigint")
    val text get() = ColumnBuilder(type = "text")
    val int get() = ColumnBuilder(type = "int")

    fun build(): Table {
      return Table(schema = schema,
          name = name,
          columns = columns.map { it.build() }.toList(),
          constraints = constraints
      )
    }
}

fun table(body: TableBuilder.() -> Unit): ReadOnlyProperty<Nothing?, Table> {
    return ReadOnlyProperty { _, property ->
        val builder = TableBuilder()
        val (schema, name) = property.name.split("__")
        builder.schema = schema
        builder.name = name
        builder.body()
        builder.build()
    }

}
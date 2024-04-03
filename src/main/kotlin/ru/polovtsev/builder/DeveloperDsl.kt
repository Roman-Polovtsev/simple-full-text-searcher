package ru.polovtsev.builder


data class Developer(private var person: Person?, private var skillSet: MutableSet<String>,
                     private var company: Company?, private val salary: Int?){

}

class DeveloperBuilder {

    private var developer: Developer? = null
    private var person: Person? = null
    private var company: Company? = null


    fun build(): Developer = developer!!
}

class PersonBuilder {

     var person: Person? = null

//    fun gender(gender: Gender) = person.apply { this.gender = gender }

    fun build(): Person = person!!
}

class CompanyBuilder {

    private var company: Company? = null

    fun build(): Company = company!!
}

enum class Gender {
     MALE,FEMALE,NON_BINARY
}

data class Person( var gender: Gender, private val age: Int, private val fullname: String)

data class Company(private val name: String, private val address: String)

fun developer(builder: DeveloperBuilder.()->Unit): Developer {
    val developer = DeveloperBuilder()
   return developer.apply(builder).build()
}

fun person(builder: PersonBuilder.()->Unit): Person {
    val person = PersonBuilder()
    return person.apply(builder).build()
}

fun company(builder: CompanyBuilder.()->Unit): Company {
    val company = CompanyBuilder()
    return company.apply(builder).build()
}

fun main(){
    developer {
        person {

        }
        company {

        }


    }

}
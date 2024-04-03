package kotest

import io.kotest.assertions.assertSoftly
import io.kotest.assertions.withClue
import io.kotest.core.spec.Spec
import io.kotest.core.spec.style.StringSpec
import io.kotest.core.test.TestCase
import io.kotest.matchers.ints.shouldBeInRange
import io.kotest.matchers.ints.shouldBeLessThan
import io.kotest.matchers.shouldBe
import io.kotest.matchers.string.shouldMatch
import kotlinx.coroutines.delay
import java.time.LocalDate


abstract class BaseTest(
    val currentYear: Int = LocalDate.now().year,
    val probes: Int  = 3,
    val limit: Int  =  4) : StringSpec(){

        fun createBestTestEver(){
            "Best test for $currentYear year"{
                currentYear shouldBe  2024
            }
        }

    var testCount = 0

    override fun beforeTest(testCase: TestCase) {
        println(testCase.displayName)
        testCount++
    }

    override fun afterSpec(spec: Spec) {
        super.afterSpec(spec)
        println("launched $testCount tests")
    }

    }


class HowToTest : BaseTest(probes = 5, limit = 6, currentYear = 2045){

    init {

        createBestTestEver()

        "2+2=4"{
            delay(100)
            (2 + 2) shouldBe 4
        }


        "Best test  2 for $currentYear year"{
            this.testCase.description.name.displayName shouldBe "Best test  2 for $currentYear year"
        }

        for (i in 1..probes){
            "this number $i less then $limit"{
                i shouldBeLessThan limit
            }
        }

//    how to ignore test:

        "!deprecated test"{
            1 shouldBe 2
        }

//    how to force onky this test
//    "f: force this test"{
//        println("I'm forced")
//    }

        "checkStructure"{
            val person1 = Person("Roman", 27)
            val person2 = Person("roman", 277)
            assertSoftly {
                withClue("Name"){
                    withClue("Only letters"){
                        person1.name shouldMatch """^\p{L}+$""".toRegex()
                        person2.name shouldMatch """^\p{L}+$""".toRegex()
                    }
                    withClue("First is capital"){
                        person1.name shouldMatch """^\p{Lu}\p{Ll}""".toRegex()
                        person2.name shouldMatch """^\p{Lu}\p{Ll}""".toRegex()
                    }
                }

                withClue("Age"){
                    person1.age shouldBeInRange 1..110
                    person2.age shouldBeInRange 1..110
                }
            }
        }
    }

    data class Person(val name: String, val age: Int)
}
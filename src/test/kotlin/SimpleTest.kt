import org.junit.jupiter.api.Test
import ru.polovtsev.search.SimpleSearcher
import ru.polovtsev.util.StringExtractor

class SimpleTest {

    @Test
    fun test(){
        val data = StringExtractor.readArticleSet("src/test/resources/sample-data.txt")
        val searcher = SimpleSearcher()
        searcher.index(data)

        val results = searcher.search("hello")

        println("results = ${results}")
    }

    @Test
    fun countTest(){
        val data = StringExtractor.readArticleSet("src/test/resources/sample-data.txt")
        val searcher = SimpleSearcher()

        val results = searcher.count("hello", data)

        println("results = $results")
    }
}
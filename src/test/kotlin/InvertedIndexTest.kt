import org.junit.jupiter.api.Test
import ru.polovtsev.search.InvertedIndexSearcher
import ru.polovtsev.util.StringExtractor

class InvertedIndexTest {

    @Test
    fun a(){
        val data = StringExtractor.readArticleSet("src/test/resources/sample-data.txt")
        val searcher = InvertedIndexSearcher()
        searcher.index(data)

        println(searcher.sourceData)

        val search = searcher.search("Hello", data)

        println("search = $search")
    }
}
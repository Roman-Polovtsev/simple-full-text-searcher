import org.junit.jupiter.api.Test
import ru.polovtsev.index.PositionedInvertedIndex
import ru.polovtsev.search.InvertedIndexSearcher
import ru.polovtsev.search.PositionedIndexSearcher
import ru.polovtsev.util.StringExtractor

class PositionedInvertedIndexTest {


    @Test
    fun a(){
        val data = StringExtractor.readArticleSet("src/test/resources/sample-data.txt")
        val searcher = PositionedIndexSearcher()
        searcher.index(data)

        println(searcher.index)

//        val search = searcher.search("Hello", data)
//
//        println("search = $search")
    }
}
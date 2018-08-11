import com.jaunt.JNode;
import com.jaunt.JauntException;
import com.jaunt.UserAgent;

/**
 * Created by Manu on 12/19/2017.
 */
public class ScrapeTest {

    public static void main(String[] args) {
        try {
            String jishoBase = "http://jisho.org/api/v1/search/words?keyword=";
            String query = "house";
            UserAgent uAgent = new UserAgent();
            uAgent.sendGET(jishoBase + query);
            JNode response = uAgent.json.getFirst("data").findEvery("japanese");
            for(JNode r: response) {
                System.out.println(r.get(0).get("reading"));
            }

        } catch(JauntException e) {
            System.out.println("Query could not be processed");
        }
    }
}

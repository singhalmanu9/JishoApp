package github.jishoapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.jaunt.JNode;
import com.jaunt.JauntException;
import com.jaunt.UserAgent;

public class DisplayQueryActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_query);
        Intent intent = getIntent();
        UserAgent searched = search(intent.getStringExtra(SearchActivity.EXTRA_MESSAGE));

        String processed = process(searched);
        TextView tv = findViewById(R.id.loleroni);
        tv.setText(processed);
    }

    public UserAgent search(String query) {
        String jishoBase = "http://jisho.org/api/v1/search/words?keyword=";
        UserAgent uAgent = new UserAgent();
        try {
            uAgent.sendGET(jishoBase + query);
        } catch (JauntException e) {
            e.printStackTrace();
        }
        return uAgent;
    }

    public String process(UserAgent searched) {
        String out;
        try {
            JNode resp = searched.json.getFirst("data").findEvery("japanese");
            StringBuilder outBuilder = new StringBuilder();
            for(JNode r : resp) {
                outBuilder.append(r.get(0).get("japanese"));
            }
            out = outBuilder.toString();
        } catch (JauntException e) {
            out = "Could not process request.";
        }
        return out;
    }
}

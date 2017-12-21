package c.example.jisho;

import android.content.Intent;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

import org.json.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class DisplayQueryActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_query);
        Intent intent = getIntent();

        String processed = "http://jisho.org/api/v1/search/words?keyword=" + intent.getStringExtra(SearchActivity.EXTRA_MESSAGE);
        new Search().execute(processed);
        TextView tv = findViewById(R.id.loleroni);
        tv.setText(processed);
    }

    private class Search extends AsyncTask<String, Void, JSONArray> {
        protected JSONArray doInBackground(String... query) {
            try {
                URL url = new URL(query[0]);
                HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                try {
                    BufferedReader bufferedReader = new BufferedReader(new
                            InputStreamReader(urlConnection.getInputStream()));
                    StringBuilder stringBuilder = new StringBuilder();
                    String line;
                    while ((line = bufferedReader.readLine()) != null) {
                        stringBuilder.append(line).append("\n");
                    }
                    bufferedReader.close();
                            //FIXME doesn't work as intended
                    return new JSONArray((stringBuilder.toString()));
                }
                finally {
                    urlConnection.disconnect();
                }
            } catch (Exception e) {
                Log.e("ERROR", e.getMessage(), e);
                return  null;
            }
        }
        protected void onPostExecute(JSONArray response) {
            //FIXME will parse the JSON array and construct the results page.
        }
    }
}

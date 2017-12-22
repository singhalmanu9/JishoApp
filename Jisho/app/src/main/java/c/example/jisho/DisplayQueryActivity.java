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

    public static final String API = "http://jisho.org/api/v1/search/words?keyword=";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_query);
        Intent intent = getIntent();

        new Search().execute(intent);
    }

    private class Search extends AsyncTask<Intent, Void, String> {
        protected String doInBackground(Intent... intent) {
            try {
                URL url = new URL(API + intent[0].getStringExtra(SearchActivity.EXTRA_MESSAGE).toLowerCase());
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
                    return stringBuilder.toString();
                }
                finally {
                    urlConnection.disconnect();
                }
            } catch (Exception e) {
                Log.e("ERROR", e.getMessage(), e);
                return  null;
            }
        }
        protected void onPostExecute(String response) {
            //FIXME will parse the JSON array and construct the results page.
            String processed;
            if (response == null ) {
                processed = "there was an error :(";
            } else {
                try {
                    JSONObject object = (JSONObject) new JSONTokener(response).nextValue();
                    processed = object.toString(5);
                } catch (JSONException e) {
                    processed = "there was an error :(";
                }
            }
            TextView tv = findViewById(R.id.loleroni);
            tv.setText(processed);
        }
    }
}

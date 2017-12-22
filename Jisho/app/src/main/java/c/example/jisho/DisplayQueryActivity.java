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
                    return stringBuilder.toString();
                } finally {
                    urlConnection.disconnect();
                }
            } catch (Exception e) {
                Log.e("ERROR", e.getMessage(), e);
                return null;
            }
        }

        protected void onPostExecute(String response) {

            String processed;
            if (response == null) {
                processed = "there was an error :(";
            } else {
                try {
                    JSONObject object = (JSONObject) new JSONTokener(response).nextValue();
                    textViewCreate(object);
                    processed = object.toString(5);
                } catch (JSONException e) {
                    processed = "there was an error :(";
                }
            }
            TextView tv = findViewById(R.id.loleroni);
            tv.setText(processed);
            //FIXME need to remove unnecessary lines here.
        }

        /**
         * creates the TextView objects for a query.
         *
         * @param object the JSONObject received by a query.
         * @throws JSONException handled in higher frame.
         */
        protected void textViewCreate(JSONObject object)
                throws JSONException {
            JSONArray array = object.getJSONArray("data");
            for (int i = 0; array.getJSONObject(i) != null; i++) {
                objTextViewCreate(array.getJSONObject(i));
            }
        }

        /**
         * creates the TextView for a single translation of the query.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objTextViewCreate(JSONObject object)
                throws JSONException {
            objCommonTV(object);
            objJPTV(object);
            objENGTV(object);

        }

        /**
         * creates the TextView that describes
         * whether a translation of the query is common.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objCommonTV(JSONObject object)
                throws JSONException {
            //FIXME
        }

        /**
         * creates the TextView corresponding to the
         * Japanese script for a translation of the query.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objJPTV(JSONObject object)
                throws JSONException {
            //FIXME
        }

        /**
         * creates the TextView corresponding to the
         * English definitions of the Japanese word given as a translation
         * of the query.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objENGTV(JSONObject object)
                throws JSONException {
            objPartSpeechTV(object);
            //FIXME
        }

        /**
         * creates the TextView corresponding to the part of speech
         * that is given for an English translation of the Japanese word.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objPartSpeechTV(JSONObject object)
                throws JSONException {
            //FIXME
        }
    }
}

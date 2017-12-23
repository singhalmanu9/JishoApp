package c.example.jisho;

import android.content.Intent;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.LinearLayout;
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
            if (response == null) {
                errorMessageCreate();
            } else {
                try {
                    JSONObject object = (JSONObject) new JSONTokener(response).nextValue();
                    textViewCreate(object);
                } catch (JSONException e) {
                    errorMessageCreate();
                }
            }
            //FIXME need to remove unnecessary lines here.
        }

        protected void errorMessageCreate() {
            LinearLayout linlay = findViewById(R.id.llMain);
            TextView err = new TextView(getApplicationContext());
            err.setText("Query could not be processed.");
            linlay.addView(err);
        }

        /**
         * creates the TextView objects for a query.
         *
         * @param object the JSONObject received by a query.
         * @throws JSONException handled in higher frame.
         */
        @SuppressWarnings("InfiniteLoopStatement")
        protected void textViewCreate(JSONObject object) {
            try {
                JSONArray array = object.getJSONArray("data");
                if (array.isNull(0)) {
                    errorMessageCreate();
                    return;
                }
                int i = 0;
                while (true) {
                    objTextViewCreate(array.getJSONObject(i));
                    i++;
                }
            } catch (JSONException e) {
                System.err.println("end of query reached.");
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
            objSenseTV(object);

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
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            if (object.getBoolean("is_common")) {
                TextView txt = new TextView(getApplicationContext());
                txt.setLayoutParams(new LinearLayout.LayoutParams
                        (LinearLayout.LayoutParams.FILL_PARENT,
                                LinearLayout.LayoutParams.WRAP_CONTENT));
                txt.setText("Common");
                linlay.addView(txt);
            } else {
                //not necessary, but for clarity.
                return;
            }
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
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            JSONArray x =  object.getJSONArray("japanese");
            JSONObject jpObj = x.getJSONObject(0);
            TextView textWord = new TextView(getApplicationContext());
            TextView textReading = new TextView(getApplicationContext());
            textWord.setLayoutParams(new LinearLayout.LayoutParams
                (LinearLayout.LayoutParams.FILL_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT));
            textReading.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.FILL_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT));
            textWord.setText(jpObj.getString("word"));
            textReading.setText(jpObj.getString("reading"));
            linlay.addView(textReading);
            linlay.addView(textWord);
        }

        /**
         * creates the TextView corresponding to the
         * English definitions of the Japanese word given as a translation
         * of the query.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objENGTV(JSONObject object) {
            objPartSpeechTV(object);
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            TextView txt = new TextView(getApplicationContext());
            txt.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.FILL_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT));
            StringBuilder x = new StringBuilder();
            try {
                JSONArray englishDefinitions = object.getJSONArray("english_definitions");
                int i = 0;
                while (true) {
                    x.append(englishDefinitions.getString(i) + "; ");
                    i++;
                }
            } catch (JSONException e) {
                System.err.println("ENGLISH DEF PARSING COMPLETE.");
            }
            txt.setText(x.toString());
            linlay.addView(txt);
        }

        /**
         * creates the TextView corresponding to the part of speech
         * that is given for an English translation of the Japanese word.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objPartSpeechTV(JSONObject object) {
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            TextView txt = new TextView(getApplicationContext());
            txt.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.FILL_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT));
            StringBuilder x = new StringBuilder();
            try {
                JSONArray partsOfSpeech = object.getJSONArray("parts_of_speech");
                int i = 0;
                while (true) {
                    x.append(partsOfSpeech.getString(i) + ", ");
                    i++;
                }
            } catch (JSONException e) {
                System.err.println("PARTS OF SPEECH PARSING COMPLETE.");
            }
            txt.setText(x.toString());
            linlay.addView(txt);
        }

        /**
         * creates the TextView for the senses of a word. this handles
         * the English part of the text
         * @param object the JSONObject that needs parsing.
         */
        protected void objSenseTV(JSONObject object) {
            try {
                JSONArray senses = object.getJSONArray("senses");
                int i = 0;
                while (true) {
                    objENGTV(senses.getJSONObject(i));
                    i++;
                }
            } catch (JSONException e) {
                System.err.println("OBJECT SENSE ITERATION FINISHED.");
            }
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            TextView linebreak = new TextView(getApplicationContext());
            linebreak.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.FILL_PARENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT));
            linebreak.setText("");
            linlay.addView(linebreak);
        }
    }
}

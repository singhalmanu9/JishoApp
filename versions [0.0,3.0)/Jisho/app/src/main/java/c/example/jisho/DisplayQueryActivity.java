package c.example.jisho;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.MainThread;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.w3c.dom.Text;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import javax.net.ssl.HttpsURLConnection;

public class DisplayQueryActivity extends AppCompatActivity {

    public static final String API = "https://jisho.org/api/v1/search/words?keyword=";
    public ArrayList<String> kanji = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_query);
        Intent intent = getIntent();

        SharedPreferences sp = getApplicationContext().getSharedPreferences("myprefs", Context.MODE_PRIVATE);
        if (!sp.contains("opened")) {
            SharedPreferences.Editor editor = sp.edit();
            TextView toastTV = new TextView(this);
            toastTV.setBackgroundColor(Color.rgb(80,80,80));
            toastTV.setTextColor(Color.WHITE);
            toastTV.setTextSize(30);
            toastTV.setText(R.string.kanjDispHelp);
            toastTV.setPadding(10, 10, 10, 10);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                toastTV.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            }
            Toast t = new Toast(getApplicationContext());
            t.setView(toastTV);
            t.setGravity(Gravity.BOTTOM, 0, 100);
            t.show();

            editor.putBoolean("opened", true);
            editor.apply();
        }

        new Search().execute(intent);
    }

    private class Search extends AsyncTask<Intent, Void, String> {
        @MainThread
        protected String doInBackground(Intent... intent) {
            try {
                String query = intent[0].getStringExtra(SearchActivity.EXTRA_MESSAGE);
                URL url = new URL(API + query);
                HttpsURLConnection urlConnection = (HttpsURLConnection) url.openConnection();
                String queryResult = displayQuery(query);
                final LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
                final TextView queryTV = new TextView(getApplicationContext());
                queryTV.setText(queryResult);
                queryTV.setTextSize(18);
                queryTV.setTextColor(Color.rgb(80,80,80));
                queryTV.setTextIsSelectable(true);

                /* makes Ui thread the only thread to update Ui */
                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        linlay.addView(queryTV);
                        linlay.addView(new TextView(getApplicationContext()));
                    }
                });
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
                System.out.println(e.getMessage());
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
                    System.out.println(object.toString(5));
                    textViewCreate(object);

                } catch (JSONException js) {
                    errorMessageCreate();
                }
            }
        }

        protected void errorMessageCreate() {
            LinearLayout linlay = findViewById(R.id.llMain);
            TextView err = new TextView(getApplicationContext());
            err.setText("Query could not be processed or query has no results.");
            linlay.addView(err);
        }
        /**
         * Displays the query in hiragana, romaji, or some twisted combination
         * of the two scripts (based on the input of the user).
         * @param query the query to be displayed.
         * @return the String that is transliterated.
         **/
        protected String displayQuery(String query) {
            if (query.charAt(0) != '"' && isRomaji(query)) {
                query = new RomajiToHira().convert(query.toLowerCase());
            } else {
                if (query.charAt(0) != '"') {
                    query = "\"" + query + "\"";
                }
            }
            String queryResult = "Displaying search results for: " + query ;
            return queryResult;
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
                while (!array.isNull(i)) {
                    JSONObject obj = array.getJSONObject(i);
                    objTextViewCreate(obj);
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
            objJPTV(object);
            objCommonTV(object);
            objSenseTV(object);
        }

        /**
         * creates the TextView that describes
         * whether a translation of the query is common.
         *
         * @param object the JSONObject for a single translation of the query.
         * @throws JSONException handled in higher frame.
         */
        protected void objCommonTV(JSONObject object){
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            try {
                if (object.getBoolean("is_common")) {
                    TextView txt = new TextView(getApplicationContext());
                    txt.setLayoutParams(new LinearLayout.LayoutParams
                            (LinearLayout.LayoutParams.WRAP_CONTENT,
                                    LinearLayout.LayoutParams.WRAP_CONTENT));
                    txt.setText("Common");
                    txt.setBackgroundColor(Color.rgb(200, 0, 200));
                    txt.setTextColor(Color.rgb(255, 255, 255));
                    txt.setTextIsSelectable(true);
                    linlay.addView(txt);
                }
            } catch (JSONException e) {
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

            // get pertinent japanese
            JSONArray x =  object.getJSONArray("japanese");
            final JSONObject jpObj = x.getJSONObject(0);

            // make and set several params for TV
            TextView textWord = new TextView(getApplicationContext());
            TextView textReading = new TextView(getApplicationContext());
            textWord.setLayoutParams(new LinearLayout.LayoutParams
                            (LinearLayout.LayoutParams.WRAP_CONTENT,
                                    LinearLayout.LayoutParams.WRAP_CONTENT));
            textReading.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.WRAP_CONTENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT));
            try {
                textReading.setText(jpObj.getString("reading"));
                textReading.setTextSize(24);
                textReading.setTextColor(Color.rgb(80,80,80));
                textReading.setTextIsSelectable(true);
                linlay.addView(textReading);

            } catch (JSONException e) {}
            try {
                textWord.setText(jpObj.getString("word"));
                textWord.setTextSize(48);
                textWord.setTextColor(Color.rgb(80,80,80));
                textWord.setClickable(true);
                textWord.setOnClickListener(new View.OnClickListener() {
                                                public void onClick(View view) {
                                                    try {
                                                        openKanjiPages(jpObj.getString("word"));
                                                    } catch (JSONException e) {}
                                                }});
                textWord.setTextIsSelectable(true);
                linlay.addView(textWord);
            } catch (JSONException e) {}
            Boolean romanization = getIntent().getBooleanExtra("ROMANIZATION", false);
            if (romanization) {
                TextView romaji = new TextView(getApplicationContext());
                romaji.setLayoutParams(new LinearLayout.LayoutParams
                        (LinearLayout.LayoutParams.WRAP_CONTENT,
                                LinearLayout.LayoutParams.WRAP_CONTENT));
                romaji.setText(new KanaToRoma().toRomaji(jpObj.getString("reading")));
                romaji.setTextSize(24);
                romaji.setTextColor(Color.rgb(80,80,80));
                romaji.setTypeface(null, Typeface.ITALIC);
                romaji.setTextIsSelectable(true);
                linlay.addView(romaji);
            }
        }

        /**
         * creates the TextView corresponding to the
         * English definitions of the Japanese word given as a translation
         * of the query.
         *
         * @param object the JSONObject for a single translation of the query.
         * @param defCount the # of the english definition for the word. i.e 1, 2, 3 ...
         *                 ex: 漢字
         *                 1. chinese characters.
         *                 2. chinese characters.
         * @throws JSONException handled in higher frame.
         */
        protected void objENGTV(JSONObject object, int defCount) {
            objPartSpeechTV(object);
            defCount++;
            LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
            TextView txt = new TextView(getApplicationContext());
            txt.setLayoutParams(new LinearLayout.LayoutParams
                    (LinearLayout.LayoutParams.WRAP_CONTENT,
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
            txt.setTextSize(24);
            String definitionLine = defCount + ". " + x.toString();
            txt.setText(definitionLine);
            txt.setTextColor(Color.rgb(80,80,80));
            txt.setTextIsSelectable(true);
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
                    (LinearLayout.LayoutParams.WRAP_CONTENT,
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
            txt.setTextColor(Color.rgb(80,80,80));
            txt.setTextIsSelectable(true);
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
                    objENGTV(senses.getJSONObject(i), i);
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

        /**
         * A method to detect whether a given string is romaji.
         * @param query the string to be tested for romaji.
         * @return whether the string is completely romaji or not.
         */
        protected boolean isRomaji(String query) {
            RomajiToHira x = new RomajiToHira();
            for (int i = 0; i != query.length(); i++) {
                if (!x.isConsonant(query.charAt(i)) && !x.isVowel(query.charAt(i))) {
                    return false;
                }
            }
            String hira = x.convert(query);
            for (char c : hira.toCharArray()) {
                if (x.isConsonant(c) || x.isVowel(c)) {
                    return false;
                }
            }
            return true;
        }
    }

    /**
     * Opens the pertinent kanji pages for each kanji present
     * in the queried word
     * @param word
     */
    protected void openKanjiPages(String word) {
        HashSet<String> kana = populateKana();
        kanji.clear();
        for (char c: word.toCharArray()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                if (Character.isIdeographic(c)) {
                    kanji.add(c + "");
                }
            } else {
                if (!kana.contains(c + "") && !(c == 'ゃ' || c == 'ょ' || c == 'ゅ')) {
                    kanji.add(c + "");
                }
            }
        }
        if (kanji.size() != 0) {
            Intent i = new Intent(this, KanjiPageActivity.class);
            i.putExtra("KANJI", kanji.toArray(new String[kanji.size()]));
            startActivity(i);
        }
    }

    /**
     * Displays helpful message on the kanji page (double tap
     * brings up kanji information)
     */
    public void displayHelp(View view) {
        SharedPreferences sp = getApplicationContext().getSharedPreferences("myprefs", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        TextView toastTV = new TextView(this);
        toastTV.setBackgroundColor(Color.rgb(80,80,80));
        toastTV.setTextColor(Color.WHITE);
        toastTV.setTextSize(30);
        toastTV.setText(R.string.kanjDispHelp);
        toastTV.setPadding(10, 10, 10, 10);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            toastTV.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
        }
        Toast t = new Toast(getApplicationContext());
        t.setView(toastTV);
        t.setGravity(Gravity.BOTTOM, 0, 100);
        t.show();

        editor.putBoolean("opened", true);
        editor.apply();
    }

    /**
     *
     */
    protected HashSet<String> populateKana() {
        KanaToRoma kr = new KanaToRoma();
        return new HashSet<>(kr.kana.keySet());
    }

    /**
     * A class that facilitates transliteration from kana to romaji.
     * @author Tim Toombs
     */
    private class KanaToRoma{
        /**
         * the mapping of each katakana and hiragana to its respective romanization. adapted from
         * kakasi-java.
         */
        HashMap<String, String> kana = new HashMap<String, String>();

        // Constructor
        private KanaToRoma() {
            kana.put("\u30a1", "a");
            kana.put("\u30a2", "a");
            kana.put("\u30a3", "i");
            kana.put("\u30a4", "i");
            kana.put("\u30a5", "u");
            kana.put("\u30a6", "u");
            kana.put("\u30a7", "e");
            kana.put("\u30a8", "e");
            kana.put("\u30a9", "o");
            kana.put("\u30aa", "o");
            kana.put("\u30ab", "ka");
            kana.put("\u30ac", "ga");
            kana.put("\u30ad", "ki");
            kana.put("\u30ad\u30e3", "kya");
            kana.put("\u30ad\u30e5", "kyu");
            kana.put("\u30ad\u30e7", "kyo");
            kana.put("\u30ae", "gi");
            kana.put("\u30ae\u30e3", "gya");
            kana.put("\u30ae\u30e5", "gyu");
            kana.put("\u30ae\u30e7", "gyo");
            kana.put("\u30af", "ku");
            kana.put("\u30b0", "gu");
            kana.put("\u30b1", "ke");
            kana.put("\u30b2", "ge");
            kana.put("\u30b3", "ko");
            kana.put("\u30b4", "go");
            kana.put("\u30b5", "sa");
            kana.put("\u30b6", "za");
            kana.put("\u30b7", "shi");
            kana.put("\u30b7\u30e3", "sha");
            kana.put("\u30b7\u30e5", "shu");
            kana.put("\u30b7\u30e7", "sho");
            kana.put("\u30b8", "ji");
            kana.put("\u30b8\u30e3", "ja");
            kana.put("\u30b8\u30e5", "ju");
            kana.put("\u30b8\u30e7", "jo");
            kana.put("\u30b9", "su");
            kana.put("\u30ba", "zu");
            kana.put("\u30bb", "se");
            kana.put("\u30bc", "ze");
            kana.put("\u30bd", "so");
            kana.put("\u30be", "zo");
            kana.put("\u30bf", "ta");
            kana.put("\u30c0", "da");
            kana.put("\u30c1", "chi");
            kana.put("\u30c1\u30e3", "cha");
            kana.put("\u30c1\u30e5", "chu");
            kana.put("\u30c1\u30e7", "cho");
            kana.put("\u30c2", "di");
            kana.put("\u30c2\u30e3", "dya");
            kana.put("\u30c2\u30e5", "dyu");
            kana.put("\u30c2\u30e7", "dyo");
            kana.put("\u30c3", "tsu");
            kana.put("\u30c3\u30ab", "kka");
            kana.put("\u30c3\u30ac", "gga");
            kana.put("\u30c3\u30ad", "kki");
            kana.put("\u30c3\u30ad\u30e3", "kkya");
            kana.put("\u30c3\u30ad\u30e5", "kkyu");
            kana.put("\u30c3\u30ad\u30e7", "kkyo");
            kana.put("\u30c3\u30ae", "ggi");
            kana.put("\u30c3\u30ae\u30e3", "ggya");
            kana.put("\u30c3\u30ae\u30e5", "ggyu");
            kana.put("\u30c3\u30ae\u30e7", "ggyo");
            kana.put("\u30c3\u30af", "kku");
            kana.put("\u30c3\u30b0", "ggu");
            kana.put("\u30c3\u30b1", "kke");
            kana.put("\u30c3\u30b2", "gge");
            kana.put("\u30c3\u30b3", "kko");
            kana.put("\u30c3\u30b4", "ggo");
            kana.put("\u30c3\u30b5", "ssa");
            kana.put("\u30c3\u30b6", "zza");
            kana.put("\u30c3\u30b7", "sshi");
            kana.put("\u30c3\u30b7\u30e3", "ssha");
            kana.put("\u30c3\u30b7\u30e5", "sshu");
            kana.put("\u30c3\u30b7\u30e7", "ssho");
            kana.put("\u30c3\u30b8", "jji");
            kana.put("\u30c3\u30b8\u30e3", "jja");
            kana.put("\u30c3\u30b8\u30e5", "jju");
            kana.put("\u30c3\u30b8\u30e7", "jjo");
            kana.put("\u30c3\u30b9", "ssu");
            kana.put("\u30c3\u30ba", "zzu");
            kana.put("\u30c3\u30bb", "sse");
            kana.put("\u30c3\u30bc", "zze");
            kana.put("\u30c3\u30bd", "sso");
            kana.put("\u30c3\u30be", "zzo");
            kana.put("\u30c3\u30bf", "tta");
            kana.put("\u30c3\u30c0", "dda");
            kana.put("\u30c3\u30c1", "cchi");
            kana.put("\u30c3\u30c1\u30e3", "ccha");
            kana.put("\u30c3\u30c1\u30e5", "cchu");
            kana.put("\u30c3\u30c1\u30e7", "ccho");
            kana.put("\u30c3\u30c2", "ddi");
            kana.put("\u30c3\u30c2\u30e3", "ddya");
            kana.put("\u30c3\u30c2\u30e5", "ddyu");
            kana.put("\u30c3\u30c2\u30e7", "ddyo");
            kana.put("\u30c3\u30c4", "ttsu");
            kana.put("\u30c3\u30c5", "ddu");
            kana.put("\u30c3\u30c6", "tte");
            kana.put("\u30c3\u30c7", "dde");
            kana.put("\u30c3\u30c8", "tto");
            kana.put("\u30c3\u30c9", "ddo");
            kana.put("\u30c3\u30cf", "hha");
            kana.put("\u30c3\u30d0", "bba");
            kana.put("\u30c3\u30d1", "ppa");
            kana.put("\u30c3\u30d2", "hhi");
            kana.put("\u30c3\u30d2\u30e3", "hhya");
            kana.put("\u30c3\u30d2\u30e5", "hhyu");
            kana.put("\u30c3\u30d2\u30e7", "hhyo");
            kana.put("\u30c3\u30d3", "bbi");
            kana.put("\u30c3\u30d3\u30e3", "bbya");
            kana.put("\u30c3\u30d3\u30e5", "bbyu");
            kana.put("\u30c3\u30d3\u30e7", "bbyo");
            kana.put("\u30c3\u30d4", "ppi");
            kana.put("\u30c3\u30d4\u30e3", "ppya");
            kana.put("\u30c3\u30d4\u30e5", "ppyu");
            kana.put("\u30c3\u30d4\u30e7", "ppyo");
            kana.put("\u30c3\u30d5", "ffu");
            kana.put("\u30c3\u30d5\u30a1", "ffa");
            kana.put("\u30c3\u30d5\u30a3", "ffi");
            kana.put("\u30c3\u30d5\u30a7", "ffe");
            kana.put("\u30c3\u30d5\u30a9", "ffo");
            kana.put("\u30c3\u30d6", "bbu");
            kana.put("\u30c3\u30d7", "ppu");
            kana.put("\u30c3\u30d8", "hhe");
            kana.put("\u30c3\u30d9", "bbe");
            kana.put("\u30c3\u30da", "ppe");
            kana.put("\u30c3\u30db", "hho");
            kana.put("\u30c3\u30dc", "bbo");
            kana.put("\u30c3\u30dd", "ppo");
            kana.put("\u30c3\u30e4", "yya");
            kana.put("\u30c3\u30e6", "yyu");
            kana.put("\u30c3\u30e8", "yyo");
            kana.put("\u30c3\u30e9", "rra");
            kana.put("\u30c3\u30ea", "rri");
            kana.put("\u30c3\u30ea\u30e3", "rrya");
            kana.put("\u30c3\u30ea\u30e5", "rryu");
            kana.put("\u30c3\u30ea\u30e7", "rryo");
            kana.put("\u30c3\u30eb", "rru");
            kana.put("\u30c3\u30ec", "rre");
            kana.put("\u30c3\u30ed", "rro");
            kana.put("\u30c3\u30f4", "vvu");
            kana.put("\u30c3\u30f4\u30a1", "vva");
            kana.put("\u30c3\u30f4\u30a3", "vvi");
            kana.put("\u30c3\u30f4\u30a7", "vve");
            kana.put("\u30c3\u30f4\u30a9", "vvo");
            kana.put("\u30c4", "tsu");
            kana.put("\u30c5", "du");
            kana.put("\u30c6", "te");
            kana.put("\u30c7", "de");
            kana.put("\u30c8", "to");
            kana.put("\u30c9", "do");
            kana.put("\u30ca", "na");
            kana.put("\u30cb", "ni");
            kana.put("\u30cb\u30e3", "nya");
            kana.put("\u30cb\u30e5", "nyu");
            kana.put("\u30cb\u30e7", "nyo");
            kana.put("\u30cc", "nu");
            kana.put("\u30cd", "ne");
            kana.put("\u30ce", "no");
            kana.put("\u30cf", "ha");
            kana.put("\u30d0", "ba");
            kana.put("\u30d1", "pa");
            kana.put("\u30d2", "hi");
            kana.put("\u30d2\u30e3", "hya");
            kana.put("\u30d2\u30e5", "hyu");
            kana.put("\u30d2\u30e7", "hyo");
            kana.put("\u30d3", "bi");
            kana.put("\u30d3\u30e3", "bya");
            kana.put("\u30d3\u30e5", "byu");
            kana.put("\u30d3\u30e7", "byo");
            kana.put("\u30d4", "pi");
            kana.put("\u30d4\u30e3", "pya");
            kana.put("\u30d4\u30e5", "pyu");
            kana.put("\u30d4\u30e7", "pyo");
            kana.put("\u30d5", "fu");
            kana.put("\u30d5\u30a1", "fa");
            kana.put("\u30d5\u30a3", "fi");
            kana.put("\u30d5\u30a7", "fe");
            kana.put("\u30d5\u30a9", "fo");
            kana.put("\u30d6", "bu");
            kana.put("\u30d7", "pu");
            kana.put("\u30d8", "he");
            kana.put("\u30d9", "be");
            kana.put("\u30da", "pe");
            kana.put("\u30db", "ho");
            kana.put("\u30dc", "bo");
            kana.put("\u30dd", "po");
            kana.put("\u30de", "ma");
            kana.put("\u30df", "mi");
            kana.put("\u30df\u30e3", "mya");
            kana.put("\u30df\u30e5", "myu");
            kana.put("\u30df\u30e7", "myo");
            kana.put("\u30e0", "mu");
            kana.put("\u30e1", "me");
            kana.put("\u30e2", "mo");
            kana.put("\u30e3", "ya");
            kana.put("\u30e4", "ya");
            kana.put("\u30e5", "yu");
            kana.put("\u30e6", "yu");
            kana.put("\u30e7", "yo");
            kana.put("\u30e8", "yo");
            kana.put("\u30e9", "ra");
            kana.put("\u30ea", "ri");
            kana.put("\u30ea\u30e3", "rya");
            kana.put("\u30ea\u30e5", "ryu");
            kana.put("\u30ea\u30e7", "ryo");
            kana.put("\u30eb", "ru");
            kana.put("\u30ec", "re");
            kana.put("\u30ed", "ro");
            kana.put("\u30ee", "wa");
            kana.put("\u30ef", "wa");
            kana.put("\u30f0", "i");
            kana.put("\u30f1", "e");
            kana.put("\u30f2", "wo");
            kana.put("\u30f3", "n");
            kana.put("\u30f3\u30a2", "n'a");
            kana.put("\u30f3\u30a4", "n'i");
            kana.put("\u30f3\u30a6", "n'u");
            kana.put("\u30f3\u30a8", "n'e");
            kana.put("\u30f3\u30aa", "n'o");
            kana.put("\u30f4", "vu");
            kana.put("\u30f4\u30a1", "va");
            kana.put("\u30f4\u30a3", "vi");
            kana.put("\u30f4\u30a7", "ve");
            kana.put("\u30f4\u30a9", "vo");
            kana.put("\u30f5", "ka");
            kana.put("\u30f6", "ke");
            kana.put("\u30fc", "^");
            kana.put("\u3041", "a");
            kana.put("\u3042", "a");
            kana.put("\u3043", "i");
            kana.put("\u3044", "i");
            kana.put("\u3045", "u");
            kana.put("\u3046", "u");
            kana.put("\u3046\u309b", "vu");
            kana.put("\u3046\u309b\u3041", "va");
            kana.put("\u3046\u309b\u3043", "vi");
            kana.put("\u3046\u309b\u3047", "ve");
            kana.put("\u3046\u309b\u3049", "vo");
            kana.put("\u3047", "e");
            kana.put("\u3048", "e");
            kana.put("\u3049", "o");
            kana.put("\u304a", "o");
            kana.put("\u304b", "ka");
            kana.put("\u304c", "ga");
            kana.put("\u304d", "ki");
            kana.put("\u304d\u3083", "kya");
            kana.put("\u304d\u3085", "kyu");
            kana.put("\u304d\u3087", "kyo");
            kana.put("\u304e", "gi");
            kana.put("\u304e\u3083", "gya");
            kana.put("\u304e\u3085", "gyu");
            kana.put("\u304e\u3087", "gyo");
            kana.put("\u304f", "ku");
            kana.put("\u3050", "gu");
            kana.put("\u3051", "ke");
            kana.put("\u3052", "ge");
            kana.put("\u3053", "ko");
            kana.put("\u3054", "go");
            kana.put("\u3055", "sa");
            kana.put("\u3056", "za");
            kana.put("\u3057", "shi");
            kana.put("\u3057\u3083", "sha");
            kana.put("\u3057\u3085", "shu");
            kana.put("\u3057\u3087", "sho");
            kana.put("\u3058", "ji");
            kana.put("\u3058\u3083", "ja");
            kana.put("\u3058\u3085", "ju");
            kana.put("\u3058\u3087", "jo");
            kana.put("\u3059", "su");
            kana.put("\u305a", "zu");
            kana.put("\u305b", "se");
            kana.put("\u305c", "ze");
            kana.put("\u305d", "so");
            kana.put("\u305e", "zo");
            kana.put("\u305f", "ta");
            kana.put("\u3060", "da");
            kana.put("\u3061", "chi");
            kana.put("\u3061\u3083", "cha");
            kana.put("\u3061\u3085", "chu");
            kana.put("\u3061\u3087", "cho");
            kana.put("\u3062", "di");
            kana.put("\u3062\u3083", "dya");
            kana.put("\u3062\u3085", "dyu");
            kana.put("\u3062\u3087", "dyo");
            kana.put("\u3063", "tsu");
            kana.put("\u3063\u3046\u309b", "vvu");
            kana.put("\u3063\u3046\u309b\u3041", "vva");
            kana.put("\u3063\u3046\u309b\u3043", "vvi");
            kana.put("\u3063\u3046\u309b\u3047", "vve");
            kana.put("\u3063\u3046\u309b\u3049", "vvo");
            kana.put("\u3063\u304b", "kka");
            kana.put("\u3063\u304c", "gga");
            kana.put("\u3063\u304d", "kki");
            kana.put("\u3063\u304d\u3083", "kkya");
            kana.put("\u3063\u304d\u3085", "kkyu");
            kana.put("\u3063\u304d\u3087", "kkyo");
            kana.put("\u3063\u304e", "ggi");
            kana.put("\u3063\u304e\u3083", "ggya");
            kana.put("\u3063\u304e\u3085", "ggyu");
            kana.put("\u3063\u304e\u3087", "ggyo");
            kana.put("\u3063\u304f", "kku");
            kana.put("\u3063\u3050", "ggu");
            kana.put("\u3063\u3051", "kke");
            kana.put("\u3063\u3052", "gge");
            kana.put("\u3063\u3053", "kko");
            kana.put("\u3063\u3054", "ggo");
            kana.put("\u3063\u3055", "ssa");
            kana.put("\u3063\u3056", "zza");
            kana.put("\u3063\u3057", "sshi");
            kana.put("\u3063\u3057\u3083", "ssha");
            kana.put("\u3063\u3057\u3085", "sshu");
            kana.put("\u3063\u3057\u3087", "ssho");
            kana.put("\u3063\u3058", "jji");
            kana.put("\u3063\u3058\u3083", "jja");
            kana.put("\u3063\u3058\u3085", "jju");
            kana.put("\u3063\u3058\u3087", "jjo");
            kana.put("\u3063\u3059", "ssu");
            kana.put("\u3063\u305a", "zzu");
            kana.put("\u3063\u305b", "sse");
            kana.put("\u3063\u305c", "zze");
            kana.put("\u3063\u305d", "sso");
            kana.put("\u3063\u305e", "zzo");
            kana.put("\u3063\u305f", "tta");
            kana.put("\u3063\u3060", "dda");
            kana.put("\u3063\u3061", "cchi");
            kana.put("\u3063\u3061\u3083", "ccha");
            kana.put("\u3063\u3061\u3085", "cchu");
            kana.put("\u3063\u3061\u3087", "ccho");
            kana.put("\u3063\u3062", "ddi");
            kana.put("\u3063\u3062\u3083", "ddya");
            kana.put("\u3063\u3062\u3085", "ddyu");
            kana.put("\u3063\u3062\u3087", "ddyo");
            kana.put("\u3063\u3064", "ttsu");
            kana.put("\u3063\u3065", "ddu");
            kana.put("\u3063\u3066", "tte");
            kana.put("\u3063\u3067", "dde");
            kana.put("\u3063\u3068", "tto");
            kana.put("\u3063\u3069", "ddo");
            kana.put("\u3063\u306f", "hha");
            kana.put("\u3063\u3070", "bba");
            kana.put("\u3063\u3071", "ppa");
            kana.put("\u3063\u3072", "hhi");
            kana.put("\u3063\u3072\u3083", "hhya");
            kana.put("\u3063\u3072\u3085", "hhyu");
            kana.put("\u3063\u3072\u3087", "hhyo");
            kana.put("\u3063\u3073", "bbi");
            kana.put("\u3063\u3073\u3083", "bbya");
            kana.put("\u3063\u3073\u3085", "bbyu");
            kana.put("\u3063\u3073\u3087", "bbyo");
            kana.put("\u3063\u3074", "ppi");
            kana.put("\u3063\u3074\u3083", "ppya");
            kana.put("\u3063\u3074\u3085", "ppyu");
            kana.put("\u3063\u3074\u3087", "ppyo");
            kana.put("\u3063\u3075", "ffu");
            kana.put("\u3063\u3075\u3041", "ffa");
            kana.put("\u3063\u3075\u3043", "ffi");
            kana.put("\u3063\u3075\u3047", "ffe");
            kana.put("\u3063\u3075\u3049", "ffo");
            kana.put("\u3063\u3076", "bbu");
            kana.put("\u3063\u3077", "ppu");
            kana.put("\u3063\u3078", "hhe");
            kana.put("\u3063\u3079", "bbe");
            kana.put("\u3063\u307a", "ppe");
            kana.put("\u3063\u307b", "hho");
            kana.put("\u3063\u307c", "bbo");
            kana.put("\u3063\u307d", "ppo");
            kana.put("\u3063\u3084", "yya");
            kana.put("\u3063\u3086", "yyu");
            kana.put("\u3063\u3088", "yyo");
            kana.put("\u3063\u3089", "rra");
            kana.put("\u3063\u308a", "rri");
            kana.put("\u3063\u308a\u3083", "rrya");
            kana.put("\u3063\u308a\u3085", "rryu");
            kana.put("\u3063\u308a\u3087", "rryo");
            kana.put("\u3063\u308b", "rru");
            kana.put("\u3063\u308c", "rre");
            kana.put("\u3063\u308d", "rro");
            kana.put("\u3064", "tsu");
            kana.put("\u3065", "du");
            kana.put("\u3066", "te");
            kana.put("\u3067", "de");
            kana.put("\u3068", "to");
            kana.put("\u3069", "do");
            kana.put("\u306a", "na");
            kana.put("\u306b", "ni");
            kana.put("\u306b\u3083", "nya");
            kana.put("\u306b\u3085", "nyu");
            kana.put("\u306b\u3087", "nyo");
            kana.put("\u306c", "nu");
            kana.put("\u306d", "ne");
            kana.put("\u306e", "no");
            kana.put("\u306f", "ha");
            kana.put("\u3070", "ba");
            kana.put("\u3071", "pa");
            kana.put("\u3072", "hi");
            kana.put("\u3072\u3083", "hya");
            kana.put("\u3072\u3085", "hyu");
            kana.put("\u3072\u3087", "hyo");
            kana.put("\u3073", "bi");
            kana.put("\u3073\u3083", "bya");
            kana.put("\u3073\u3085", "byu");
            kana.put("\u3073\u3087", "byo");
            kana.put("\u3074", "pi");
            kana.put("\u3074\u3083", "pya");
            kana.put("\u3074\u3085", "pyu");
            kana.put("\u3074\u3087", "pyo");
            kana.put("\u3075", "fu");
            kana.put("\u3075\u3041", "fa");
            kana.put("\u3075\u3043", "fi");
            kana.put("\u3075\u3047", "fe");
            kana.put("\u3075\u3049", "fo");
            kana.put("\u3076", "bu");
            kana.put("\u3077", "pu");
            kana.put("\u3078", "he");
            kana.put("\u3079", "be");
            kana.put("\u307a", "pe");
            kana.put("\u307b", "ho");
            kana.put("\u307c", "bo");
            kana.put("\u307d", "po");
            kana.put("\u307e", "ma");
            kana.put("\u307f", "mi");
            kana.put("\u307f\u3083", "mya");
            kana.put("\u307f\u3085", "myu");
            kana.put("\u307f\u3087", "myo");
            kana.put("\u3080", "mu");
            kana.put("\u3081", "me");
            kana.put("\u3082", "mo");
            kana.put("\u3083", "ya");
            kana.put("\u3084", "ya");
            kana.put("\u3085", "yu");
            kana.put("\u3086", "yu");
            kana.put("\u3087", "yo");
            kana.put("\u3088", "yo");
            kana.put("\u3089", "ra");
            kana.put("\u308a", "ri");
            kana.put("\u308a\u3083", "rya");
            kana.put("\u308a\u3085", "ryu");
            kana.put("\u308a\u3087", "ryo");
            kana.put("\u308b", "ru");
            kana.put("\u308c", "re");
            kana.put("\u308d", "ro");
            kana.put("\u308e", "wa");
            kana.put("\u308f", "wa");
            kana.put("\u3090", "i");
            kana.put("\u3091", "e");
            kana.put("\u3092", "wo");
            kana.put("\u3093", "n");
            kana.put("\u3093\u3042", "n'a");
            kana.put("\u3093\u3044", "n'i");
            kana.put("\u3093\u3046", "n'u");
            kana.put("\u3093\u3048", "n'e");
            kana.put("\u3093\u304a", "n'o");
        }

        /**
         * converts a string of kana into its romanization.
         * @param s an input of kana.
         * @return a string of romanized kana.
         */
        private String toRomaji(String s) {
            StringBuilder t = new StringBuilder();
            for ( int i = 0; i < s.length(); i++ ) {
                if ( i <= s.length() - 2 )  {
                    if ( kana.containsKey(s.substring(i,i+2))) {
                        t.append(kana.get(s.substring(i, i+2)));
                        i++;
                    } else if (kana.containsKey(s.substring(i, i+1))) {
                        t.append(kana.get(s.substring(i, i+1)));
                    } else if ( s.charAt(i) == 'ッ' || s.charAt(i) == 'っ') {
                        t.append(kana.get(s.substring(i+1, i+2)).charAt(0));
                    } else {
                        t.append(s.charAt(i));
                    }
                } else {
                    if (kana.containsKey(s.substring(i, i+1))) {
                        t.append(kana.get(s.substring(i, i+1)));
                    } else {
                        t.append(s.charAt(i));
                    }
                }
            }
            return t.toString();
        }

    }
    /**
     * A class that can facilitate transliteration from Romaji to Hiragana
     * @author Tim Toombs
     */
    private class RomajiToHira {
        /**
         * this is a map of valid English inputs
         * to their respective Hiragana character.
         */
        private HashMap<String, String>  conversionMap= new HashMap();
        /**
         * this is map of valid English inputs that
         * correspond to digraph syllables in Hiragana.
         * an example of this would be 'shu' which maps to しゅ.
         * this could also be a HashSet.
         */
        private HashMap<String,String> specialDigraphMap = new HashMap<>();
        /**
         * this maps valid English inputs that correspond
         * correspond to digraph syllables in Hiragana.
         * These, however are only two romaji character in lengtgh.
         * An example of this would be 'jo' which maps to じょ.
         * this could also be a HashSet.
         */
        private HashMap<String,String> digraphMap = new HashMap<>();

        /**
         * this is the only available constructor of the class.
         * this initializes the three Hashmaps.
         */
        public RomajiToHira() {
            digraphMap.put("sha", "しゃ");
            digraphMap.put("sh", "shu");
            digraphMap.put("sho", "sho");
            digraphMap.put("ky","きゃ");
            digraphMap.put("ch","ちゃ");
            digraphMap.put("ny","にゃ");
            digraphMap.put("hy","ひゃ");
            digraphMap.put("my","みょ");
            digraphMap.put("ry", "りょ");
            digraphMap.put("sy", "しょ");
            digraphMap.put("ty","ちょ");
            digraphMap.put("jy","じょ");
            digraphMap.put("by","びゃ");
            digraphMap.put("py","ぴゃ");
            specialDigraphMap.put("ja","じゃ");
            specialDigraphMap.put("ju","じゅ");
            specialDigraphMap.put("jo","じょ");
            conversionMap.put("a", "あ");
            conversionMap.put("i","い");
            conversionMap.put("u","う");
            conversionMap.put("e","え");
            conversionMap.put("o","お");
            conversionMap.put("ka","か");
            conversionMap.put("ga","が");
            conversionMap.put("ki","き");
            conversionMap.put("gi","ぎ");
            conversionMap.put("ku","く");
            conversionMap.put("gu","ぐ");
            conversionMap.put("ke","け");
            conversionMap.put("ge","げ");
            conversionMap.put("ko","こ");
            conversionMap.put("go","ご");
            conversionMap.put("sa","さ");
            conversionMap.put("za","ざ");
            conversionMap.put("si","し");
            conversionMap.put("zi","じ");
            conversionMap.put("ji","じ");
            conversionMap.put("shi","し");
            conversionMap.put("su","す");
            conversionMap.put("zu","ず");
            conversionMap.put("se","せ");
            conversionMap.put("ze","ぜ");
            conversionMap.put("so","そ");
            conversionMap.put("zo", "ぞ");
            conversionMap.put("ta","た");
            conversionMap.put("da","だ");
            conversionMap.put("chi","ち");
            conversionMap.put("di","ぢ");
            conversionMap.put("ti","ち");
            conversionMap.put("tu","つ");
            conversionMap.put("du","づ");
            conversionMap.put("dsu","づ");
            conversionMap.put("te","て");
            conversionMap.put("de","で");
            conversionMap.put("tsu","つ");
            conversionMap.put("to","と");
            conversionMap.put("do","ど");
            conversionMap.put("na","な");
            conversionMap.put("ni","に");
            conversionMap.put("nu","ぬ");
            conversionMap.put("ne","ね");
            conversionMap.put("no","の");
            conversionMap.put("ha", "は");
            conversionMap.put("ba", "ば");
            conversionMap.put("pa","ぱ");
            conversionMap.put("hi", "ひ");
            conversionMap.put("bi","び");
            conversionMap.put("pi","ぴ");
            conversionMap.put("fu", "ふ");
            conversionMap.put("bu","ぶ");
            conversionMap.put("pu","ぷ");
            conversionMap.put("hu","ふ");
            conversionMap.put("he", "へ");
            conversionMap.put("be", "べ");
            conversionMap.put("pe", "ぺ");
            conversionMap.put("ho", "ほ");
            conversionMap.put("bo", "ぼ");
            conversionMap.put("po","ぽ");
            conversionMap.put("ma", "ま");
            conversionMap.put("mi", "み");
            conversionMap.put("mu", "む");
            conversionMap.put("me", "め");
            conversionMap.put("mo", "も");
            conversionMap.put("ya", "や");
            conversionMap.put("yu", "ゆ");
            conversionMap.put("yo", "よ");
            conversionMap.put("ra", "ら");
            conversionMap.put("ri", "り");
            conversionMap.put("ru", "る");
            conversionMap.put("re", "れ");
            conversionMap.put("ro", "ろ");
            conversionMap.put("la", "ら");
            conversionMap.put("li", "り");
            conversionMap.put("lu", "る");
            conversionMap.put("le", "れ");
            conversionMap.put("lo", "ろ");
            conversionMap.put("wa", "わ");
            conversionMap.put("wo", "を");
            conversionMap.put("n", "ん");
            conversionMap.put("we", "うぇ");
            conversionMap.put("ttsu","っ");
            conversionMap.put("wi", "うぃ");
            conversionMap.put("sha", "しゃ");
            conversionMap.put("shu","しゅ");
            conversionMap.put("sho","しょ");
            conversionMap.put("kya","きゃ");
            conversionMap.put("kyu","きゅ");
            conversionMap.put("kyo","きょ");
            conversionMap.put("cha","ちゃ");
            conversionMap.put("chu","ちゅ");
            conversionMap.put("cho","ちょ");
            conversionMap.put("nya","にゃ");
            conversionMap.put("nyu","にゅ");
            conversionMap.put("nyo","にょ");
            conversionMap.put("hya","ひゃ");
            conversionMap.put("hyu","ひゅ");
            conversionMap.put("hyo","ひょ");
            conversionMap.put("mya","みゃ");
            conversionMap.put("myu","みゅ");
            conversionMap.put("myo","みょ");
            conversionMap.put("rya","りゃ");
            conversionMap.put("ryu","りゅ");
            conversionMap.put("ryo", "りょ");
            conversionMap.put("sya", "しゃ");
            conversionMap.put("syu", "しゅ");
            conversionMap.put("syo", "しょ");
            conversionMap.put("tya", "ちゃ");
            conversionMap.put("tyu","ちゅ");
            conversionMap.put("tyo","ちょ");
            conversionMap.put("jya","じゃ");
            conversionMap.put("ja","じゃ");
            conversionMap.put("jyu","じゅ");
            conversionMap.put("ju","じゅ");
            conversionMap.put("jyo","じょ");
            conversionMap.put("jo","じょ");
            conversionMap.put("bya","びゃ");
            conversionMap.put("byu","びゅ");
            conversionMap.put("byo","びょ");
            conversionMap.put("pya","ぴゃ");
            conversionMap.put("pyu", "ぴゅ");
            conversionMap.put("pyo", "ぴょ");
        }

        /**
         * converts a romaji string to hiragana.
         * If a syllable is not present, it is left in romaji.
         * @param romaji the romaji string to be converted.
         */
               String convert(String romaji) {
            StringBuilder hiragana = new StringBuilder();
            while (!romaji.equals("")) {
                char first = 0;
                char second = 0;
                if (isConsonant(romaji.charAt(0))) {
                    first = romaji.charAt(0);
                    romaji = romaji.substring(1);
                }
                if (romaji.length() == 0) {
                    if (first == 'n') {
                        hiragana.append(conversionMap.get("n"));
                    } else {
                        hiragana.append(Character.toString(first));
                    }
                    break;
                }
                if (isConsonant(romaji.charAt(0)) && first == 'n') {
                    hiragana.append(conversionMap.get("n"));
                    continue;
                } else if (isConsonant(romaji.charAt(0)) && first == romaji.charAt(0)) {
                    hiragana.append(conversionMap.get("ttsu"));
                    continue;
                }
                if (!digraph(first, romaji.charAt(0)) && !specialDigraph(first, romaji.charAt(0))) {
                    if (isVowel(romaji.charAt(0)) && first != 0) {
                        second = romaji.charAt(0);
                        romaji = romaji.substring(1);
                        String concat = Character.toString(first) + Character.toString(second);
                        hiragana.append(conversionMap.get(concat));
                        continue;
                    } else if (isVowel(romaji.charAt(0))) {
                        String concat = Character.toString(romaji.charAt(0));
                        hiragana.append(conversionMap.get(concat));
                        romaji = romaji.substring(1);
                        continue;
                    }
                } else if (specialDigraph(first, romaji.charAt(0))) {
                    String concat = Character.toString(first) + Character.toString(romaji.charAt(0));
                    hiragana.append(conversionMap.get(concat));
                    romaji = romaji.substring(1);
                    continue;
                } else if (digraph(first, romaji.charAt(0)) && isVowel(romaji.charAt(1))) {
                    String concat = Character.toString(first) + Character.toString(romaji.charAt(0));
                    romaji = romaji.substring(1);
                    concat += Character.toString(romaji.charAt(0));
                    hiragana.append(conversionMap.get(concat));
                    romaji = romaji.substring(1);
                    continue;
                }
                if (first == 'n' && romaji.charAt(0) == '\'') {
                    hiragana.append(conversionMap.get("n"));
                    romaji = romaji.substring(1);
                    continue;
                }
                if (!isVowel(romaji.charAt(0)) && !isConsonant(romaji.charAt(0))) {
                    hiragana.append(romaji.charAt(0));
                    romaji = romaji.substring(1);
                }
                if (first == 't' && romaji.charAt(0) == 's') {
                    hiragana.append(conversionMap.get("tsu"));
                    if (romaji.charAt(1) == 'u') {
                        romaji = romaji.substring(2);
                    }
                    continue;
                }
                if (first != 0) {
                    hiragana.append(first);
                }
            }
            return hiragana.toString();
        }
        
        /**
         * returns true if two characters are part of a digraph.
         * @param first the first character in a sequence.
         * @param second the second character in a sequence.
         * @return true IFF the characters form a non-special Digraph.
         * (see class' Hashmaps)
         */
        boolean digraph(char first, char second) {
            String addition = Character.toString(first) + Character.toString(second);
            return digraphMap.containsKey(addition);
        }

        /**
         * returns true if two characters form a digraph.
         * @param first the first of two characters tested.
         * @param second the second of two characters tested.
         * @return true if and only if the characters form a special Digraph.
         * (see class' Hashmaps)
         */
        boolean specialDigraph(char first, char second) {
            String addition = Character.toString(first) + Character.toString(second);
            return specialDigraphMap.containsKey(addition);
        }

        /**
         * returns true if the given character is a consonant.
         * @param character the given character.
         * @return true if and only if a character is a consonant.
         */
        boolean isConsonant(char character) {
            return "BCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz".indexOf(character) != -1;
        }

        /**
         * returns true if the given character is a vowel
         * @param character the given character.
         * @return true if and only if a character is a vowel.
         */
        boolean isVowel(char character) {
            return "AEIOUaeiou".indexOf(character) != -1;
        }
    }
}

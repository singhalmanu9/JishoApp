package c.example.jisho;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.AndroidException;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.*;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;

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
                String query = intent[0].getStringExtra(SearchActivity.EXTRA_MESSAGE);
                URL url = new URL(API + query);
                HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
                String queryResult = displayQuery(query);
                LinearLayout linlay = (LinearLayout) findViewById(R.id.llMain);
                TextView queryTV = new TextView(getApplicationContext());
                queryTV.setText(queryResult);
                queryTV.setTextSize(18);
                linlay.addView(queryTV);
                linlay.addView(new TextView(getApplicationContext()));

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
                    System.out.println(object.toString(5));
                    textViewCreate(object);
                } catch (JSONException e) {
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
            JSONObject jpObj = x.getJSONObject(0);

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
                linlay.addView(textReading);
            } catch (JSONException e) {}
            try {
                textWord.setText(jpObj.getString("word"));
                textWord.setTextSize(48);
                linlay.addView(textWord);
            } catch (JSONException e) {}

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
         * @return true IFF the characters form a special Digraph.
         * (see class' Hashmaps)
         */
        boolean specialDigraph(char first, char second) {
            String addition = Character.toString(first) + Character.toString(second);
            return specialDigraphMap.containsKey(addition);
        }
        boolean isConsonant(char character) {
            return "BCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz".indexOf(character) != -1;
        }
        boolean isVowel(char character) {
            return "AEIOUaeiou".indexOf(character) != -1;
        }
    }
}

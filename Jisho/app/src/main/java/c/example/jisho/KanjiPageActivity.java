package c.example.jisho;

import android.content.Intent;
import android.content.res.Resources;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Layout;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;

public class KanjiPageActivity extends AppCompatActivity {

    public String[] kanji = {};
    public HashMap<String, HashMap<String, ArrayList<String>>> kanjiInfo = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_kanji_page);
        Intent i = getIntent();
        kanji = i.getStringArrayExtra("KANJI");
        kanjiInfo = readStrokeMap();
        createKanjiViews();
    }

    protected void createKanjiViews() {
        LinearLayout ll = findViewById(R.id.llMain);
        ll.removeAllViews();
        for (String k: kanji) {
            TextView kanjiTV = new TextView(this);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            lp.setMargins(10, 0, 10, 0);
            kanjiTV.setLayoutParams(lp);
            kanjiTV.setText("N" + kanjiInfo.get(k).get("jlpt").get(0) + "　" + k);
            kanjiTV.setTextSize(48);
            kanjiTV.setPadding(10, 0, 0, 0);
            ll.addView(kanjiTV);

            TextView readingsTV = new TextView(this);
            readingsTV.setLayoutParams(lp);
            String read = "Readings: ";
            for (String s : kanjiInfo.get(k).get("readings"))
                read += s + ", ";
            readingsTV.setText(read);
            readingsTV.setTextSize(24);
            readingsTV.setPadding(10, 0, 0, 0);
            ll.addView(readingsTV);

            TextView meaningsTV = new TextView(this);
            meaningsTV.setLayoutParams(lp);
            String mean = "Meanings: ";
            for (String s : kanjiInfo.get(k).get("meanings"))
                mean += s + ", ";
            meaningsTV.setText(mean);
            meaningsTV.setTextSize(24);
            meaningsTV.setPadding(10, 0, 0, 0);
            ll.addView(meaningsTV);

            TextView nameTV = new TextView(this);
            nameTV.setLayoutParams(lp);
            String names = "Name Readings: ";
            for (String s : kanjiInfo.get(k).get("nanori"))
                names += s + ", ";
            nameTV.setText(names);
            nameTV.setTextSize(24);
            nameTV.setPadding(10, 0, 0, 0);
            ll.addView(nameTV);
        }
    }

    /**
     * reads in the strokeMap from a serialized file of it.
     * @return the strokeMap from a serialized file.
     */
    protected HashMap<String, HashMap<String, ArrayList<String>>> readStrokeMap() {
        HashMap<String, HashMap<String, ArrayList<String>>> obj;
        Resources x = getResources();
        try {

            ObjectInputStream inp =
                    new ObjectInputStream(x.openRawResource(R.raw.kanjimap));
            obj = (HashMap<String, HashMap<String, ArrayList<String>>>) inp.readObject();
            inp.close();
        } catch (IOException e) {
            e.printStackTrace();
            obj = null;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            obj = null;
        }
        return obj;
    }
}

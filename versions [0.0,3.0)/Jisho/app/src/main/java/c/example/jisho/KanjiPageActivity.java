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
    public static HashMap<String, HashMap<String, ArrayList<String>>> kanjiInfo = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_kanji_page);
        Intent i = getIntent();
        kanji = i.getStringArrayExtra("KANJI");
        createKanjiViews();
    }

    public static void setKanjiInfo(HashMap<String, HashMap<String, ArrayList<String>>> inf) {
        kanjiInfo = inf;
    }

    protected void createKanjiViews() {
        LinearLayout ll = findViewById(R.id.llMain);
        ll.removeAllViews();
        for (String k: kanji) {
            TextView kanjiTV = new TextView(this);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            lp.setMargins(10, 10, 10, 0);
            kanjiTV.setLayoutParams(lp);
            if (!kanjiInfo.containsKey(k)) {
                kanjiTV.setText("No information about "+ k +"! :(");
                kanjiTV.setTextSize(36);
                kanjiTV.setPadding(10, 0, 0, 0);
                ll.addView(kanjiTV);
            } else {
                if (kanjiInfo.get(k).get("jlpt").get(0) != null) {
                    kanjiTV.setText("N" + kanjiInfo.get(k).get("jlpt").get(0) + "　" + k);
                } else {
                    kanjiTV.setText(" 　　" + k);
                }
                kanjiTV.setTextSize(48);
                kanjiTV.setPadding(10, 0, 0, 0);
                kanjiTV.setTextIsSelectable(true);
                ll.addView(kanjiTV);

                TextView readingsTV = new TextView(this);
                readingsTV.setLayoutParams(lp);
                String read = "Readings: ";
                for (String s : kanjiInfo.get(k).get("readings"))
                    read += s + ", ";
                readingsTV.setText(read);
                readingsTV.setTextSize(24);
                readingsTV.setPadding(10, 0, 0, 0);
                readingsTV.setTextIsSelectable(true);
                ll.addView(readingsTV);

                TextView meaningsTV = new TextView(this);
                meaningsTV.setLayoutParams(lp);
                String mean = "Meanings: ";
                for (String s : kanjiInfo.get(k).get("meanings"))
                    mean += s + ", ";
                meaningsTV.setText(mean);
                meaningsTV.setTextSize(24);
                meaningsTV.setPadding(10, 0, 0, 0);
                meaningsTV.setTextIsSelectable(true);
                ll.addView(meaningsTV);

                TextView nameTV = new TextView(this);
                nameTV.setLayoutParams(lp);
                String names = "Name Readings: ";
                for (String s : kanjiInfo.get(k).get("nanori"))
                    names += s + ", ";
                nameTV.setText(names);
                nameTV.setTextSize(24);
                nameTV.setPadding(10, 0, 0, 0);
                nameTV.setTextIsSelectable(true);
                ll.addView(nameTV);
            }
        }
    }
}

package c.example.jisho;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class RadSearchActivity extends AppCompatActivity {

    public RadSearchActivity() {}

    private static HashMap<Integer, ArrayList<String>> strokeMap;
    private static HashMap<String, ArrayList<String>> radicalMap;
    private static HashSet<String> radicalsSelected;
    private static HashSet<String> kanji;
    private static HashMap<String, String> unicodeMap;
    public static final String EXTRA_MESSAGE = "github.jishoapp.MESSAGE";

    /**
     * reads in the strokeMap from a serialized file of it.
     * @return the strokeMap from a serialized file.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    protected HashMap<Integer, ArrayList<String>> readStrokeMap() {
        HashMap<Integer, ArrayList<String>> obj;
        Resources x = getResources();
        try {

            ObjectInputStream inp =
                    new ObjectInputStream(x.openRawResource(R.raw.strokemap));
            obj = (HashMap<Integer, ArrayList<String>>) inp.readObject();
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

    /**
     * reads in the RadicalMap from a serialized file of it.
     * @return the radicalMap from a serialized file.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    protected HashMap<String, ArrayList<String>> readRadicalMap() throws PackageManager.NameNotFoundException {
        HashMap<String, ArrayList<String>> obj;
        Resources x = getResources();
        try {

            ObjectInputStream inp =
                    new ObjectInputStream(x.openRawResource(R.raw.radicalmap));
            obj = (HashMap<String, ArrayList<String>>) inp.readObject();
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

    protected void fillTable(TableLayout table) {
        ArrayList<String> allRadicals = new ArrayList<String>();
        for (int i : strokeMap.keySet()) {
            allRadicals.add(i + "");
            allRadicals.addAll(strokeMap.get(i));
        }

        TableRow row = new TableRow(this);
        int count = 0;
        for (final String rad : allRadicals) {
            if (count > 7) {
                count = 0;
                table.addView(row);
                row = new TableRow(this);
            }

            final ImageButton button = new ImageButton(this);
            if (rad.matches("\\d+")) {
                button.setImageResource(getResources().getIdentifier("stroke" + rad, "drawable", getPackageName()));
                button.setBackgroundColor(Color.WHITE);
            } else {
                String drawId = "r" + unicodeMap.get(rad).substring(2);
                button.setImageResource(getResources().getIdentifier(drawId, "drawable", getPackageName()));
                button.setBackgroundColor(Color.WHITE);
                button.setOnClickListener(new View.OnClickListener() {
                    public void onClick(View view) {
                        if (radicalsSelected.contains(rad)) {
                            removefromSet(rad);
                            button.setBackgroundColor(Color.WHITE);
                        } else {
                            newIntersect(rad);
                            button.setBackgroundColor(Color.GREEN);
                        }
                        updateDisplayKanji();
                    }
                });
            }
            row.addView(button);
            count ++;
        }
        table.addView(row);
    }

    protected void updateDisplayKanji() {
        LinearLayout kanjiLay = findViewById(R.id.kanjilay);
        kanjiLay.removeAllViews();
        if (kanji != null) {
            for (final String k : kanji) {
                Button kButton = new Button(this);
                kButton.setText(k);
                kButton.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
                kButton.setOnClickListener(new View.OnClickListener() {
                    public void onClick(View view) {
                        EditText editText = findViewById(R.id.editText);
                        editText.setText(editText.getText().toString() + k, TextView.BufferType.EDITABLE);
                    }
                });
                kanjiLay.addView(kButton);
            }
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rad_search);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        try {
            strokeMap = readStrokeMap();
            radicalMap = readRadicalMap();
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        unicodeMap = generateUnicodeMap();
        radicalsSelected = new HashSet<>();
        kanji = new HashSet<>();
        TableLayout radtable = findViewById(R.id.tableLayout);
        fillTable(radtable);
    }

    /**
     * searches the Jisho.org API given a user-defined query.
     * @param view
     */
    public void search(View view) {
        Intent i = new Intent(this, DisplayQueryActivity.class);
        EditText editText = findViewById(R.id.editText);
        String query = editText.getText().toString();
        if (query.isEmpty()){
            Toast t = Toast.makeText(getApplicationContext(), R.string.plsenter, Toast.LENGTH_SHORT);
            t.setGravity(Gravity.TOP, 0, 0);
            t.show();
        }
        else {
            i.putExtra(EXTRA_MESSAGE, query);
            CheckBox romanization = findViewById(R.id.romanization);
            Boolean ROMANIZATION = romanization.isChecked();
            i.putExtra(EXTRA_MESSAGE, query);
            i.putExtra("ROMANIZATION",ROMANIZATION);
            startActivity(i);
        }
    }

    /**
     * adds a radical into radicalsSelected and intersects kanji with the characters provided by
     * radicalMap when using radical as a key.
     * @param radical the radical that's set will be used to intersect.
     */
    protected void newIntersect(String radical) {
        if (!radicalsSelected.isEmpty()) {
            kanji.retainAll(radicalMap.get(radical));
        } else {
            kanji.addAll(radicalMap.get(radical));
        }
        radicalsSelected.add(radical);
    }

    /**
     * removes the radical from radicalsSelected and recalculates kanji.
     * @param radical the radical that will be removed.
     */
    protected void removefromSet(String radical) {
        radicalsSelected.remove(radical);
        HashSet<String> newKanji = new HashSet<String>();
        for(String rad: radicalsSelected) {
            newKanji = new HashSet<>(radicalMap.get(rad));
            break;
        }
        if(!newKanji.isEmpty()) {
            for (String rad : radicalsSelected) {
                newKanji.retainAll(radicalMap.get(rad));
            }
        }
        kanji = newKanji;
    }

    protected HashMap<String, String> generateUnicodeMap() {
        HashMap<String, String> uniMap = new HashMap<>();
        for(String radical : radicalMap.keySet()) {
            uniMap.put(radical, unicodeEscaped(radical.charAt(0)));
        }
        System.out.println("finished gen");
        return uniMap;
    }

    /**
     * gives the UTF-16 value of a character.
     * @param ch the character being converted to unicode.
     * @return a string that is equivalent to the UTF-16 code of a character.
     */
    public static String unicodeEscaped(char ch) {
        if (ch < 0x10) {
            return "\\u000" + Integer.toHexString(ch);
        } else if (ch < 0x100) {
            return "\\u00" + Integer.toHexString(ch);
        } else if (ch < 0x1000) {
            return "\\u0" + Integer.toHexString(ch);
        }
        return "\\u" + Integer.toHexString(ch);
    }
}

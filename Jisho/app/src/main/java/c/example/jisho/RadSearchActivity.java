package c.example.jisho;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.Toast;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
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
//        int[] dim = {286/5 + 1, 5};
//
//        for(int i = 0; i < dim[0]; i ++) {
//            TableRow row = new TableRow(this);
//            for (int j = 0; j < dim[1]; j++) {
//                ImageButton rad = new ImageButton(this);
//                rad.setImageResource(getResources().getIdentifier("r4e00", "drawable", getPackageName()));
//                row.addView(rad);
//            }
//            table.addView(row);
//        }

        ArrayList<String> allRadicals = new ArrayList<String>();
        for (int i : strokeMap.keySet()) {
            allRadicals.addAll(strokeMap.get(i));
        }

        TableRow row = new TableRow(this);
        int count = 0;
        for (String rad : allRadicals) {
            if (count > 4) {
                count = 0;
                table.addView(row);
                row = new TableRow(this);
            }
            ImageButton button = new ImageButton(this);
            String drawId = "r" + unicodeMap.get(rad).substring(2);
            button.setImageResource(getResources().getIdentifier(drawId, "drawable", getPackageName()));
            row.addView(button);
            count ++;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rad_search);
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

    protected void search(View view) {
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
            startActivity(i);
        }
    }

    /**
     * adds a radical into radicalsSelected and intersects kanji with the characters provided by
     * radicalMap when using radical as a key.
     * @param radical the radical that's set will be used to intersect.
     */
    protected void newIntersect(String radical) {
         radicalsSelected.add(radical);
         kanji.retainAll(radicalMap.get(radical));
    }

    /**
     * removes the radical from radicalsSelected and recalculates kanji.
     * @param radical the radical that will be removed.
     */
    protected void removefromSet(String radical) {
        radicalsSelected.remove(radical);
        HashSet<String> newKanji = null;
        for(String rad: radicalsSelected) {
            newKanji = new HashSet<>(radicalMap.get(rad));
            break;
        }
        if(newKanji != null) {
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

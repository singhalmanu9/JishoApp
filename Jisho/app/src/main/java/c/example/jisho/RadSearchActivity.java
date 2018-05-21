package c.example.jisho;

import android.content.Intent;
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
    private static HashMap<String, Integer> strokeMap;
    private static HashMap<String, ArrayList<String>> radicalMap;
    private static HashSet<String> radicalsSelected;
    private static HashSet<String> kanji;

    public static final String EXTRA_MESSAGE = "github.jishoapp.MESSAGE";

    /**
     * reads in the strokeMap from a serialized file of it.
     * @return the strokeMap from a serialized file.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    protected HashMap<String, Integer> readStrokeMap() {
        HashMap<String, Integer> obj;
        Path currentRelativePath = Paths.get("");
        String s = currentRelativePath.toAbsolutePath().toString();
        File inFile = new File(s, "strokeMap.dat");
        try {
            ObjectInputStream inp =
                    new ObjectInputStream(new FileInputStream(inFile));
            obj = (HashMap<String, Integer>) inp.readObject();
            inp.close();
        } catch (IOException |
                ClassNotFoundException excp) {

            obj = null;
        }
        return obj;
    }

    /**
     * reads in the RadicalMap from a serialized file of it.
     * @return the radicalMap from a serialized file.
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    protected HashMap<String, ArrayList<String>> readRadicalMap() {
        HashMap<String, ArrayList<String>> obj;
        Path currentRelativePath = Paths.get("");
        String s = currentRelativePath.toAbsolutePath().toString();
        File inFile = new File(s, "radicalMap.dat");
        try {
            ObjectInputStream inp =
                    new ObjectInputStream(new FileInputStream(inFile));
            obj = (HashMap<String, ArrayList<String>>) inp.readObject();
            inp.close();
        } catch (IOException |
                ClassNotFoundException excp) {
            obj = null;
        }
        return obj;
    }

    protected void fillTable(TableLayout table) {
        int[] dim = {286/5 + 1, 5};

        for(int i = 0; i < dim[0]; i ++) {
            TableRow row = new TableRow(this);
            for (int j = 0; j < dim[1]; j++) {
                ImageButton rad = new ImageButton(this);
                rad.setImageResource(getResources().getIdentifier("r4e00", "drawable", getPackageName()));
                row.addView(rad);
            }
            table.addView(row);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rad_search);
        strokeMap = readStrokeMap();
        radicalMap = readRadicalMap();
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
}

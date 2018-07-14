package c.example.jisho;

import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;

public class SearchActivity extends AppCompatActivity {

    public static final String EXTRA_MESSAGE = "github.jishoapp.MESSAGE";
    public HashMap<String, HashMap<String, ArrayList<String>>> kanjiInfo = new HashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        Intent i = new Intent(this, LoadKanjiService.class);
        startService(i);
    }

    /**
     * reads in the strokeMap from a serialized file of it.
     * @return the strokeMap from a serialized file.
     */
    protected void readKMap() {
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
        KanjiPageActivity.setKanjiInfo(obj);
        Toast t = Toast.makeText(getApplicationContext(), "Kanji loaded", Toast.LENGTH_SHORT);
        t.setGravity(Gravity.TOP, 0, 0);
        t.show();
    }

    /**
     * Searches the Jisho.org API given a user-defined query.
     * @param view not used.
     */
    public void search(View view) {
        Intent i = new Intent(this, DisplayQueryActivity.class);
        EditText editText = findViewById(R.id.searchField);
        String query = editText.getText().toString();
        if (query.isEmpty()){
            Toast t = Toast.makeText(getApplicationContext(), R.string.plsenter, Toast.LENGTH_SHORT);
            t.setGravity(Gravity.TOP, 0, 0);
            t.show();
        }
        else {
            CheckBox romanization = findViewById(R.id.romanization);
            Boolean ROMANIZATION = romanization.isChecked();
            i.putExtra(EXTRA_MESSAGE, query);
            i.putExtra("ROMANIZATION",ROMANIZATION);
            startActivity(i);
        }
    }

    /**
     * transitions to the AboutActivity.
     * @param view not used.
     */
    public void openAbout(View view) {
        Intent i = new Intent(this, AboutActivity.class);
        startActivity(i);
    }

    /**
     * transitions to the RadSearchActivity.
     * @param view not used.
     */
    public void openRad(View view) {
        Intent i = new Intent(this, RadSearchActivity.class);
        startActivity(i);
    }

}

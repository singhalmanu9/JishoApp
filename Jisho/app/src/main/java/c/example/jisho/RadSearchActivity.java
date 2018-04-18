package c.example.jisho;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import java.io.File;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;


public class RadSearchActivity extends AppCompatActivity {
    private RadSearchActivity() {}
    private static HashMap<String, Integer> strokeMap;
    private static HashMap<String, ArrayList<String>> radicalMap;
    private static HashSet<String> radicalsSelected;
    private static HashSet<String> kanji;

    protected HashMap<String, Integer> readstrokeMap() {
        HashMap<String, Integer> obj;
        File inFile = new File("./strokeMap.dat");
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
    protected HashMap<String, ArrayList<String>> readRadicalMap() {
        HashMap<String, ArrayList<String>> obj;
        File inFile = new File("./radicalMap.dat");
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
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rad_search);
        strokeMap = readstrokeMap();
        radicalMap = readRadicalMap();
        radicalsSelected = new HashSet<>();
        kanji = new HashSet<>();
    }

    protected void newIntersect(String radical) {
         radicalsSelected.add(radical);
         kanji.retainAll(radicalMap.get(radical));
    }

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

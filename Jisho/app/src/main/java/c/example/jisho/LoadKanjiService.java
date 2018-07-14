package c.example.jisho;

import android.app.IntentService;
import android.content.Intent;
import android.content.Context;
import android.content.res.Resources;
import android.view.Gravity;
import android.widget.Toast;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * helper methods.
 */
public class LoadKanjiService extends IntentService {

    public LoadKanjiService() {
        super("LoadKanjiService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
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
}

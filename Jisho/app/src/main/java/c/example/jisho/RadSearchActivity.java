package c.example.jisho;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.Toast;

public class RadSearchActivity extends AppCompatActivity {

    public static final String EXTRA_MESSAGE = "github.jishoapp.MESSAGE";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rad_search);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

        TableLayout radList = findViewById(R.id.tableLayout);
        for (int i = 0; i < 26; i ++) {
            TableRow row = new TableRow(this);
            TableRow.LayoutParams lp = new TableRow.LayoutParams(TableRow.LayoutParams.WRAP_CONTENT);
            row.setLayoutParams(lp);
            for (int j = 0; j < 10; j ++) {
                ImageButton rad = new ImageButton(this);
                rad.setImageResource(R.drawable.ichi);
                row.addView(rad);
            }
            radList.addView(row);
        }
    }

    public void onRadPush(View view) {

    }

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
            startActivity(i);
        }
    }
}

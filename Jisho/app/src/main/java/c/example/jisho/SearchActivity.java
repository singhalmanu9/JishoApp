package c.example.jisho;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.Toast;

public class SearchActivity extends AppCompatActivity {

    public static final String EXTRA_MESSAGE = "github.jishoapp.MESSAGE";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
    }

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
            i.putExtra(EXTRA_MESSAGE, query);
            startActivity(i);
        }
    }

}

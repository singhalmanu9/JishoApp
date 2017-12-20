package c.example.jisho;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

public class DisplayQueryActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display_query);
        Intent intent = getIntent();

        String processed = "http://jisho.org/api/v1/search/words?keyword=" + intent.getStringExtra(SearchActivity.EXTRA_MESSAGE);
        TextView tv = findViewById(R.id.loleroni);
        tv.setText(processed);
    }
}

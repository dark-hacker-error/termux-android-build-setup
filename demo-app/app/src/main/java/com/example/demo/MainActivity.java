package com.example.demo;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    static { System.loadLibrary("demo"); }
    public static native String nativeInfo();
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        TextView tv = new TextView(this);
        tv.setTextSize(18);
        tv.setText("Termux Build Demo\n\nJava: " + System.getProperty("java.version") + "\n" + nativeInfo());
        setContentView(tv);
    }
}

package haxe.ui.backend.android;

import android.app.Activity;
import android.os.Bundle;

class MainActivity extends Activity {
    @:overload
    public override function onCreate(savedInstanceState:Bundle) {
        super.onCreate(savedInstanceState);
        trace("FROM AND BUIT!!!!!!");
    }
}

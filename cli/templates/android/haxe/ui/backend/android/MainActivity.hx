package haxe.ui.backend.android;

import android.app.Activity;
import android.os.Bundle;

class MainActivity extends Activity {
    @:overload
    public override function onCreate(savedInstanceState:Bundle) {
        super.onCreate(savedInstanceState);
        var mainClassName = haxe.macro.Compiler.getDefine("haxe.ui.backend.android.main");
        var main = Type.resolveClass(mainClassName);
        trace("mainClassName - " + mainClassName);
        trace("main - " + main);
        Reflect.callMethod(main, Reflect.field(main, "main"), []);
    }
}

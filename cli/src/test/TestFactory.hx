package test;

import test.android.AndroidTest;

class TestFactory {
    public static function get(id:String, params:Params):Test {
        var t:Test = null;

        switch (id) {
            case "android":
                t = new AndroidTest();
            default:
                t = new BuildRun(id);
        }

        return t;
    }
}
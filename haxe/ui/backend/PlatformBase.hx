package haxe.ui.backend;

class PlatformBase {
    public function new() {
    }

    public function getMetric(id:String):Float {
        return 0;
    }

    public function getColor(id:String):Null<Int> {
        return null;
    }
    
    public function getSystemLocale():String {
        return null;
    }
}
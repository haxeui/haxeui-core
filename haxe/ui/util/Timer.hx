package haxe.ui.util;

import haxe.ui.backend.TimerBase;

class Timer extends TimerBase {
    public static function delay( f : Void -> Void, time_ms : Int ):Timer {
        var t:Timer = null;
        t = new Timer(time_ms, function() {
            t.stop();
            f();
        });
        return t;
    }

    public function new(delay:Int, callback:Void->Void) {
        super(delay, callback);
    }

    public override function stop() {
        super.stop();
    }
}

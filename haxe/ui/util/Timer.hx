package haxe.ui.util;

class Timer extends TimerBase {
    public function new(delay:Int, callback:Void->Void) {
        super(delay, callback);
    }
    
    public override function stop() {
        super.stop();
    }
}

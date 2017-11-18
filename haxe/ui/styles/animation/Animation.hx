package haxe.ui.styles.animation;

import haxe.ui.core.Component;
import haxe.ui.styles.elements.AnimationKeyFrame;

class Animation {
    private var _totalTime:Float = 0;
    
    private var _keyframes:Array<KeyFrame> = [];
    
    public function new(totalTime:Float) {
        _totalTime = totalTime;
    }
    
    public function configureKeyFrame(keyFrame:AnimationKeyFrame) {
        var kf = new KeyFrame();
        
        switch (keyFrame.time) {
            case Value.VDimension(v):
                switch (v) {
                    case Dimension.PERCENT(p):
                        trace(p);
                        var t = _totalTime * p / 100;
                        kf.time = t;
                        var lastTime:Float = 0;
                        for (a in _keyframes) {
                            lastTime += a.time;
                        }
                        trace("last time: " + lastTime + ", this time: " + t);
                        kf.time -= lastTime;
                        
                        kf.directives = keyFrame.directives;
                        
                        for (d in keyFrame.directives) {
                            //trace(d);   
                        }
                        _keyframes.push(kf);
                    case _:   
                }
            case _:
        }
    }
    
    public function run(c:Component) {
        if (_keyframes.length == 0) {
            trace("animation finished");
            return;
        }
        var kf = _keyframes.shift();
        trace("running key frame - " + kf.time);
        kf.run(c, function() {
            trace("kf complete");
            run(c);
        });
    }
}
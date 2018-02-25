package haxe.ui.styles.animation;

import haxe.ui.core.Component;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    private var _totalTime:Float;
    private var _easingFunction:EasingFunction;
    
    private var _keyframes:Array<KeyFrame> = [];
    
    public var name:String;
    
    public function new(totalTime:Float = 0, easingFunction:EasingFunction = null) {
        _totalTime = totalTime;
        _easingFunction = easingFunction;
    }

    public function configureWithKeyFrames(animationKeyFrames:AnimationKeyFrames) {
        name = animationKeyFrames.id;

        for (keyFrame in animationKeyFrames.keyFrames) {
            var kf = new KeyFrame();

            switch (keyFrame.time) {
                case Value.VDimension(v):
                    switch (v) {
                        case Dimension.PERCENT(p):
                            var t = _totalTime * p / 100;
                            kf.time = t;
                            var lastTime:Float = 0;
                            for (a in _keyframes) {
                                lastTime += a.time;
                            }
                            kf.time -= lastTime;
                            kf.easingFunction = _easingFunction;
                            kf.directives = keyFrame.directives;
                            _keyframes.push(kf);
                        case _:
                    }
                case _:
            }
        }
    }
    
    public function stop() {
        if (_currentKeyFrame != null) {
            _currentKeyFrame.stop();
            _currentKeyFrame = null;
        }
        _keyframes = [];
    }
    
    private var _currentKeyFrame:KeyFrame = null;
    public function run(c:Component, onFinish:Void->Void) {
        if (_keyframes.length == 0) {
            onFinish();
            return;
        }
        var kf = _keyframes.shift();
        _currentKeyFrame = kf;
        kf.run(c, run.bind(c, onFinish));
    }
}
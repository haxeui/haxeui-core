package haxe.ui.styles.animation;

import haxe.ui.util.StyleUtil;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    private var _target:Dynamic;
    private var _totalTime:Float;
    private var _easingFunction:EasingFunction;

    private var _currentKeyFrame:KeyFrame = null;
    private var _keyframes:Array<KeyFrame>;

    private var _initialState:Map<String, Dynamic>;
    
    public var name:String;

    public var keyframeCount(get, never):Int;
    private function get_keyframeCount():Int {
        return _keyframes == null ? 0 : _keyframes.length;
    }

    public var running(default, null):Bool;
    
    public function new(target:Dynamic, totalTime:Float = 0, easingFunction:EasingFunction = null) {
        _target = target;
        _totalTime = totalTime;
        _easingFunction = easingFunction;
    }

    public function configureWithKeyFrames(animationKeyFrames:AnimationKeyFrames) {
        name = animationKeyFrames.id;

        if (_keyframes == null) {
            _keyframes = [];
        }

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
        if (running == false) {
            return;
        }

        running = false;

        if (_currentKeyFrame != null) {
            _currentKeyFrame.stop();
            _currentKeyFrame = null;
        }

        _keyframes = null;

        restoreState();
    }
    
    public function run(onFinish:Void->Void) {
        if (keyframeCount == 0 || running) {
            return;
        }

        running = true;
        saveState();
        runNextKeyframe(onFinish);
    }

    private function runNextKeyframe(onFinish:Void->Void) {
        if (running == false) {
            return;
        }

        if (keyframeCount == 0) {
            _currentKeyFrame = null;
            restoreState();
            running = false;
            onFinish();
            return;
        }

        _currentKeyFrame = _keyframes.shift();
        _currentKeyFrame.run(_target, runNextKeyframe.bind(onFinish));
    }

    private function saveState() {
        if (_initialState == null) {
            _initialState = new Map<String, Dynamic>();
        }

        for (keyframe in _keyframes) {
            for (directive in keyframe.directives) {
                var property:String = StyleUtil.styleProperty2ComponentProperty(directive.directive);
                if (!_initialState.exists(property)) {
                    _initialState.set(property, Reflect.getProperty(_target, property));
                }
            }
        }
    }

    private function restoreState() {
        if (_initialState != null) {
            for (property in _initialState.keys()) {
                Reflect.setProperty(_target, property, _initialState.get(property));
            }

            _initialState = null;
        }
    }
}
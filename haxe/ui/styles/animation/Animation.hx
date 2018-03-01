package haxe.ui.styles.animation;

import haxe.ui.util.StyleUtil;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    private var _target:Dynamic;
    private var _duration:Float;
    private var _easingFunction:EasingFunction;
    private var _delay:Float;
    private var _iterationCount:Int;

    private var _currentKeyFrameIndex:Int = -1;
    private var _currentIterationCount:Int = -1;
    private var _keyframes:Array<KeyFrame>;

    private var _initialState:Map<String, Dynamic>;
    private var _initialized:Bool = false;

    public var name:String;

    public var keyframeCount(get, never):Int;
    private function get_keyframeCount():Int {
        return _keyframes == null ? 0 : _keyframes.length;
    }

    public var currentKeyFrame(get, never):KeyFrame;
    private function get_currentKeyFrame():KeyFrame {
        return _currentKeyFrameIndex >= 0 ? _keyframes[_currentKeyFrameIndex] : null;
    }

    public var running(default, null):Bool;
    
    public function new(target:Dynamic, duration:Float = 0, easingFunction:EasingFunction = null, delay:Float = 0, iterationCount:Int = 1) {
        _target = target;
        _duration = duration;
        _easingFunction = easingFunction != null ? easingFunction : EasingFunction.EASE;
        _delay = delay;
        _iterationCount = iterationCount;
        _currentKeyFrameIndex = -1;
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
                            var t = _duration * p / 100;
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

        var currentKF:KeyFrame = currentKeyFrame;
        if (currentKF != null) {
            currentKF.stop();
            _currentKeyFrameIndex = -1;
        }

        _keyframes = null;

        restoreState();
    }
    
    public function run(onFinish:Void->Void = null) {
        if (keyframeCount == 0 || running) {
            return;
        }

        if (!_initialized) {
            initialize();
        }

        _currentKeyFrameIndex = -1;
        _currentIterationCount = 0;
        running = true;
        saveState();
        runNextKeyframe(onFinish);
    }

    private function runNextKeyframe(onFinish:Void->Void = null) {
        if (running == false) {
            return;
        }

        if (++_currentKeyFrameIndex >= _keyframes.length) {
            _currentKeyFrameIndex = -1;
            restoreState();

            if (_iterationCount == -1 || ++_currentIterationCount < _iterationCount) {
                saveState();
                runNextKeyframe(onFinish);
            } else if (onFinish != null) {
                running = false;
                onFinish();
            }
            return;
        } else {
            currentKeyFrame.run(_target, runNextKeyframe.bind(onFinish));
        }
    }

    private function initialize() {
        if (_delay > 0) {
            var keyframe:KeyFrame = new KeyFrame();
            keyframe.time = _delay;
            keyframe.easingFunction = _easingFunction;
            _keyframes.unshift(keyframe);
        } else if (_delay < 0) {
            var currentTime:Float = 0;
            for (i in 0..._keyframes.length) {
                var keyframe:KeyFrame = _keyframes[i];
                currentTime -= keyframe.time;
                if(currentTime > _delay) {
                    _keyframes.splice(i, 1);
                } else {
                    keyframe.delay = currentTime + keyframe.time + _delay;
                    break;
                }
            }
        }

        _initialized = true;
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
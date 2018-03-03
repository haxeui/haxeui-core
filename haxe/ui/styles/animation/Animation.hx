package haxe.ui.styles.animation;

import haxe.ui.constants.AnimationDirection;
import haxe.ui.util.StyleUtil;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    public static function createWithKeyFrames(animationKeyFrames:AnimationKeyFrames, target:Dynamic, duration:Float = 0,
                    easingFunction:EasingFunction = null, delay:Float = 0,
                    iterationCount:Int = 1, direction:AnimationDirection = null):Animation {
        var animation:Animation = new Animation(target, duration, easingFunction, delay, iterationCount, direction);
        animation.name = animationKeyFrames.id;

        if (animation._keyframes == null) {
            animation._keyframes = [];
        }

        for (keyFrame in animationKeyFrames.keyFrames) {
            var kf = new KeyFrame();

            switch (keyFrame.time) {
                case Value.VDimension(v):
                    switch (v) {
                        case Dimension.PERCENT(p):
                            kf.time = p / 100;
                            kf.easingFunction = animation._easingFunction;
                            kf.directives = keyFrame.directives;
                            animation._keyframes.push(kf);
                        case _:
                    }
                case _:
            }
        }

        return animation;
    }

    private var _target:Dynamic;
    private var _duration:Float;
    private var _easingFunction:EasingFunction;
    private var _delay:Float;
    private var _iterationCount:Int;
    private var _direction:AnimationDirection;

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
    
    public function new(target:Dynamic, duration:Float = 0, easingFunction:EasingFunction = null, delay:Float = 0,
                        iterationCount:Int = 1, direction:AnimationDirection = null) {
        _target = target;
        _duration = duration;
        _easingFunction = (easingFunction != null) ? easingFunction : EasingFunction.EASE;
        _delay = delay;
        _iterationCount = iterationCount;
        _direction = (direction != null) ? direction : AnimationDirection.NORMAL;
        _currentKeyFrameIndex = -1;
    }

    public function configureWithKeyFrames(animationKeyFrames:AnimationKeyFrames) {

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
        switch (_direction) {
            case AnimationDirection.NORMAL:
                //Nothing
            case AnimationDirection.REVERSE:
                reverseCurrentKeyframes();
            case AnimationDirection.ALTERNATE:
                addAlternateKeyframes();
            case AnimationDirection.ALTERNATE_REVERSE:
                reverseCurrentKeyframes();
                addAlternateKeyframes();
        }

        var currentTime:Float = 0;
        for (keyframe in _keyframes) {
            switch (_direction) {
                case AnimationDirection.NORMAL, AnimationDirection.ALTERNATE:
                    //Nothing
                case AnimationDirection.REVERSE, AnimationDirection.ALTERNATE_REVERSE:
                    keyframe.time = 1 - keyframe.time;
            }

            keyframe.time = _duration * keyframe.time - currentTime;
            currentTime += keyframe.time;
        }

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

    private function addAlternateKeyframes() {
        var i:Int = _keyframes.length;
        while(--i >= 0) {
            var keyframe:KeyFrame = _keyframes[i];
            var newKeyframe:KeyFrame = new KeyFrame();
            newKeyframe.time = 1 - keyframe.time;
            newKeyframe.easingFunction = getReverseEasingFunction(keyframe.easingFunction);
            newKeyframe.directives = keyframe.directives;
            _keyframes.push(newKeyframe);
        }
    }

    private function reverseCurrentKeyframes() {
        _keyframes.reverse();
        var func = getReverseEasingFunction(_easingFunction);
        for(keyframe in _keyframes) {
            keyframe.easingFunction = func;
        }
    }

    private function getReverseEasingFunction(easingFunction:EasingFunction) {
        return switch(easingFunction) {
            case EasingFunction.EASE_OUT:   EasingFunction.EASE_IN;
            case EasingFunction.EASE_IN:    EasingFunction.EASE_OUT;
            case _:                         easingFunction;
        }
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
package haxe.ui.styles.animation;

import haxe.ui.constants.AnimationFillMode;
import haxe.ui.constants.AnimationDirection;
import haxe.ui.util.StyleUtil;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    public static function createWithKeyFrames(animationKeyFrames:AnimationKeyFrames, target:Dynamic, ?duration:Float,
                                               ?easingFunction:EasingFunction, ?delay:Float,
                                               ?iterationCount:Int, ?direction:AnimationDirection, ?fillMode:AnimationFillMode):Animation {
        var animation:Animation = new Animation(target, duration, easingFunction, delay, iterationCount, direction, fillMode);
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
                            kf.easingFunction = animation.easingFunction;
                            kf.directives = keyFrame.directives;
                            animation._keyframes.push(kf);
                        case _:
                    }
                case _:
            }
        }

        return animation;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     Returns the current key frame running in the animation.
    **/
    public var currentKeyFrame(get, never):KeyFrame;

    /**
     Specifies a delay for the start of an animation in seconds. If using negative values, the animation will start as if it
     had already been playing for N seconds.
    **/
    public var delay(default, null):Float = 0;

    /**
     Specifies whether an animation should be played forwards, backwards or in alternate cycles.

     @see `haxe.ui.constants.AnimationDirection`
    **/
    public var direction(default, null):AnimationDirection = AnimationDirection.NORMAL;

    /**
     Defines how long time an animation should take to complete.
    **/
    public var duration(default, null):Float = 0;

    /**
     Specifies the speed curve of the animation.

     @see `haxe.ui.styles.EasingFunction`
    **/
    public var easingFunction(default, null):EasingFunction = EasingFunction.EASE;

    /**
     Specifies a style for the target when the animation is not playing (befores it starts, after it ends, or both).

     @see `haxe.ui.constants.AnimationFillMode`
    **/
    public var fillMode(default, null):AnimationFillMode = AnimationFillMode.FORWARDS;

    /**
     Specifies the number of times an animation should run before it stops. For an infinite loop set to -1.
    **/
    public var iterationCount(default, null):Int = 1;

    /**
     Specifies the total keyframes count in the animation.
    **/
    public var keyframeCount(get, never):Int;

    /**
     The name of the animation.
    **/
    public var name:String;

    /**
     Returns if the animation is running.
    **/
    public var running(default, null):Bool;

    /**
     Specifies the target to apply the animation.
    **/
    public var target(default, null):Dynamic;

    public function new(target:Dynamic, ?duration:Float, ?easingFunction:EasingFunction, ?delay:Float,
                        ?iterationCount:Int, ?direction:AnimationDirection, ?fillMode:AnimationFillMode) {
        this.target = target;
        if (duration != null)           this.duration = duration;
        if (easingFunction != null)     this.easingFunction = easingFunction;
        if (delay != null)              this.delay = delay;
        if (iterationCount != null)     this.iterationCount = iterationCount;
        if (direction != null)          this.direction = direction;
        if (fillMode != null)           this.fillMode = fillMode;
    }

    /**
     Starts to run the animation.
    **/
    public function run(onFinish:Void->Void = null) {
        if (keyframeCount == 0 || running) {
            return;
        }

        if (!_initialized) {
            _initialize();
        }

        _currentKeyFrameIndex = -1;
        _currentIterationCount = 0;
        running = true;
        _saveState();
        _runNextKeyframe(onFinish);
    }

    /**
     Stops the animation if it is running.
    **/
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

        _restoreState();
    }

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private var _currentKeyFrameIndex:Int = -1;
    private var _currentIterationCount:Int = -1;
    private var _initialState:Map<String, Dynamic>;
    private var _initialized:Bool = false;
    private var _keyframes:Array<KeyFrame>;

    private function get_keyframeCount():Int {
        return _keyframes == null ? 0 : _keyframes.length;
    }
    private function get_currentKeyFrame():KeyFrame {
        return _currentKeyFrameIndex >= 0 ? _keyframes[_currentKeyFrameIndex] : null;
    }

    private function _initialize() {
        switch (direction) {
            case AnimationDirection.NORMAL:
                //Nothing
            case AnimationDirection.REVERSE:
                _reverseCurrentKeyframes();
            case AnimationDirection.ALTERNATE:
                _addAlternateKeyframes();
            case AnimationDirection.ALTERNATE_REVERSE:
                _reverseCurrentKeyframes();
                _addAlternateKeyframes();
        }

        var currentTime:Float = 0;
        for (keyframe in _keyframes) {
            switch (direction) {
                case AnimationDirection.NORMAL, AnimationDirection.ALTERNATE:
                    //Nothing
                case AnimationDirection.REVERSE, AnimationDirection.ALTERNATE_REVERSE:
                    keyframe.time = 1 - keyframe.time;
            }

            keyframe.time = duration * keyframe.time - currentTime;
            currentTime += keyframe.time;
        }

        if (delay > 0) {
            var keyframe:KeyFrame = new KeyFrame();
            keyframe.time = delay;
            keyframe.easingFunction = easingFunction;
            _keyframes.unshift(keyframe);
        } else if (delay < 0) {
            //Remove all frames until delay is reached. For the last keyframe, we apply a negative delay to play the animation in the exact time.
            currentTime = 0;
            var lastKeyframe:KeyFrame = null;
            while (_keyframes.length > 0) {
                var keyframe:KeyFrame = _keyframes[0];
                currentTime -= keyframe.time;
                if(currentTime >= delay) {
                    lastKeyframe = keyframe;
                    _keyframes.splice(0, 1);
                } else {
                    keyframe.delay = -(currentTime - delay + keyframe.time);
                    if(lastKeyframe != null) {
                        lastKeyframe.time = 0;
                        _keyframes.unshift(lastKeyframe);
                    }
                    break;
                }
            }
        }

        _initialized = true;
    }

    private function _runNextKeyframe(onFinish:Void->Void = null) {
        if (running == false) {
            return;
        }

        if (++_currentKeyFrameIndex >= _keyframes.length) {
            _currentKeyFrameIndex = -1;
            _restoreState();

            if (iterationCount == -1 || ++_currentIterationCount < iterationCount) {
                _saveState();
                _runNextKeyframe(onFinish);
            } else if (onFinish != null) {
                running = false;
                onFinish();
            }
            return;
        } else {
            currentKeyFrame.run(target, _runNextKeyframe.bind(onFinish));
        }
    }

    private function _addAlternateKeyframes() {
        var i:Int = _keyframes.length;
        while(--i >= 0) {
            var keyframe:KeyFrame = _keyframes[i];
            var newKeyframe:KeyFrame = new KeyFrame();
            newKeyframe.time = 1 - keyframe.time;
            newKeyframe.easingFunction = _getReverseEasingFunction(keyframe.easingFunction);
            newKeyframe.directives = keyframe.directives;
            _keyframes.push(newKeyframe);
        }
    }

    private function _reverseCurrentKeyframes() {
        _keyframes.reverse();
        var func = _getReverseEasingFunction(easingFunction);
        for(keyframe in _keyframes) {
            keyframe.easingFunction = func;
        }
    }

    private function _getReverseEasingFunction(easingFunction:EasingFunction) {
        return switch(easingFunction) {
            case EasingFunction.EASE_OUT:   EasingFunction.EASE_IN;
            case EasingFunction.EASE_IN:    EasingFunction.EASE_OUT;
            case _:                         easingFunction;
        }
    }

    private function _saveState() {
        if (!_shouldRestoreState()) {
            return;
        }

        if (_initialState == null) {
            _initialState = new Map<String, Dynamic>();
        }

        for (keyframe in _keyframes) {
            for (directive in keyframe.directives) {
                var property:String = StyleUtil.styleProperty2ComponentProperty(directive.directive);
                if (!_initialState.exists(property)) {
                    _initialState.set(property, Reflect.getProperty(target, property));
                }
            }
        }
    }

    private function _restoreState() {
        if (!_shouldRestoreState()) {
            return;
        }

        if (_initialState != null) {
            for (property in _initialState.keys()) {
                Reflect.setProperty(target, property, _initialState.get(property));
            }

            _initialState = null;
        }
    }

    private function _shouldRestoreState():Bool {
        return fillMode == AnimationFillMode.NONE ||
               (fillMode == AnimationFillMode.FORWARDS && direction != AnimationDirection.NORMAL && direction != AnimationDirection.ALTERNATE) ||
               (fillMode == AnimationFillMode.BACKWARDS && direction != AnimationDirection.REVERSE && direction != AnimationDirection.ALTERNATE_REVERSE);
    }
}
package haxe.ui.styles.animation;

import haxe.ui.util.StyleUtil;
import haxe.ui.core.Component;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.AnimationKeyFrames;

class Animation {
    private var _component:Component;
    private var _totalTime:Float;
    private var _easingFunction:EasingFunction;

    private var _currentKeyFrame:KeyFrame = null;
    private var _keyframes:Array<KeyFrame> = [];

    private var _initialState:Map<String, Dynamic>;
    
    public var name:String;
    
    public function new(component:Component, totalTime:Float = 0, easingFunction:EasingFunction = null) {
        _component = component;
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

        restoreState();
    }
    
    public function run(onFinish:Void->Void) {
        saveState();
        runNextKeyframe(onFinish);
    }

    private function runNextKeyframe(onFinish:Void->Void) {
        if (_keyframes.length == 0) {
            _currentKeyFrame = null;
            restoreState();
            onFinish();
            return;
        }

        _currentKeyFrame = _keyframes.shift();
        _currentKeyFrame.run(_component, run.bind(onFinish));
    }

    private function saveState() {
        if (_initialState == null) {
            _initialState = new Map<String, Dynamic>();
        }

        for (keyframe in _keyframes) {
            for (directive in keyframe.directives) {
                var property:String = StyleUtil.styleProperty2ComponentProperty(directive.directive);
                if (!_initialState.exists(property)) {
                    _initialState.set(property, Reflect.getProperty(_component, property));
                }
            }
        }
    }

    private function restoreState() {
        if (_initialState != null) {
            for (property in _initialState.keys()) {
                Reflect.setProperty(_component, property, _initialState.get(property));
            }
        }
    }
}
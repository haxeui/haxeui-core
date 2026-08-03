package haxe.ui.animation;

import haxe.ui.core.Component;
import haxe.ui.events.AnimationEvent;
import haxe.ui.styles.Dimension;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.Value;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.Directive;
import haxe.ui.util.Color;

@:access(haxe.ui.core.Component)
#if haxeui_expose_all
@:expose
#end
class AnimationBuilder {
    private var _keyFrames:Array<AnimationKeyFrame> = [];
    public var target:Component;
    public var onComplete:Void->Void = null;

    public var duration:Float;
    public var easing:String;

    public function new(target:Component = null, duration = .2, easing = "linear") {
        this.target = target;
        this.duration = duration;
        this.easing = easing;
    }
    
    public function shake(direction:String = "horizontal"):AnimationBuilder {
        new ShakeAnimation(target, direction).build(this);
        return this;
    }
    
    public function flash(color:Color = 0xffdddd):AnimationBuilder {
        new FlashAnimation(target, color).build(this);
        return this;
    }
    
    public function setPosition(time:Float, propertyName:String, value:Float, absolute:Bool = false):AnimationBuilder {
        var kf = findKeyFrameAtTime(time);
        if (kf == null) {
            kf = new AnimationKeyFrame();
            kf.time = Value.VDimension(Dimension.PERCENT(time));
            _keyFrames.push(kf);
        }
        if (kf.directives == null) {
            kf.directives = [];
        }
        if (absolute) {
            var directive = new Directive(propertyName, Value.VDimension(Dimension.PX(value)));
            kf.directives.push(directive);
        } else {
            var currentValue = Reflect.getProperty(target, propertyName);
            var directive = new Directive(propertyName, Value.VDimension(Dimension.PX(currentValue + value)));
            kf.directives.push(directive);
        }
        return this;
    }
    
    public function setColor(time:Float, propertyName:String, value:Color):AnimationBuilder {
        var kf = findKeyFrameAtTime(time);
        if (kf == null) {
            kf = new AnimationKeyFrame();
            kf.time = Value.VDimension(Dimension.PERCENT(time));
            _keyFrames.push(kf);
        }
        if (kf.directives == null) {
            kf.directives = [];
        }
        
        var directive = new Directive(propertyName, Value.VColor(value));
        kf.directives.push(directive);
        return this;
    }
    
    private function sortFrames() {
        _keyFrames.sort(function(f1, f2) {
            var t1:Float = 0;
            switch (f1.time) {
                case Value.VDimension(Dimension.PERCENT(p)):
                    t1 = p;
                case _:
            }
            var t2:Float = 0;
            switch (f2.time) {
                case Value.VDimension(Dimension.PERCENT(p)):
                    t2 = p;
                case _:
            }
            
            return Std.int(t1 - t2);
        });
    }
    
    public function play() {
        if (_keyFrames.length == 0) {
            if (onComplete != null) {
                onComplete();
            }
            return;
        }

        var frames = new AnimationKeyFrames("builder", _keyFrames);
        target.registerEvent(AnimationEvent.END, function(e) {
            target.invalidateComponent();
            target._pauseAnimationStyleChanges = false;
            target._componentAnimation = null;
            target.unregisterEvents(AnimationEvent.END);
            if (onComplete != null) {
                onComplete();
            }
        });

        sortFrames();
        target._pauseAnimationStyleChanges = true;
        target.applyAnimationKeyFrame(frames, {
            duration: duration,
            easingFunction: easing
        });
    }
    
    private function findKeyFrameAtTime(time:Float) {
        for (kf in _keyFrames) {
            switch (kf.time) {
                case Value.VDimension(Dimension.PERCENT(p)):
                    if (p == time) {
                        return kf;
                    }
                case _:    
            }
        }
        return null;
    }
}

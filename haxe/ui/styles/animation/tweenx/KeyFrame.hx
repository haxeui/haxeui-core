package haxe.ui.styles.animation.tweenx;
import tweenx909.TweenX;

#if tweenx

import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float = 0;
    public var delay:Float = 0;
    public var easingFunction:EasingFunction;

    public function new() {
    }
    
    public function run(target:Dynamic, cb:Void->Void) {
        var props = {
            left: ValueTools.int(directives[0].value)
        };
        var t = TweenX.to(target, props);
        t.time(time);
        t.onFinish(cb);
    }
}

#end
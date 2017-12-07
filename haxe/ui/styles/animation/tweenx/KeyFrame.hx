package haxe.ui.styles.animation.tweenx;
import tweenx909.TweenX;

#if tweenx

import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float;
    
    public function new() {
    }
    
    public function run(c:Component, cb:Void->Void) {
        var props = {
            left: ValueTools.int(directives[0].value)
        };
        var t = TweenX.to(c, props);
        t.time(time);
        t.onFinish(cb);
    }
}

#end
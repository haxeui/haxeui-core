package haxe.ui.styles.animation.actuate;

#if actuate

import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;
import motion.Actuate;
import motion.easing.Linear;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float;
    
    public function new() {
    }
    
    private var _c:Component;
    
    public function run(c:Component, cb:Void->Void) {
        _c = c;
        var props:Dynamic = { };

        for (d in directives) {
            Reflect.setField(props, d.directive, d.value);
        }

        Actuate.tween(c, time, props, true, ValueActuator).ease(Linear.easeNone).onComplete(cb);
    }
    
    public function stop() {
        Actuate.stop(_c);
    }
}

#end
package haxe.ui.styles.animation.actuate;

#if actuate

import haxe.ui.styles.EasingFunction;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.IEasing;
import motion.easing.Linear;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float;
    public var easingFunction:EasingFunction;
    
    public function new() {
    }
    
    private var _c:Component;
    
    public function run(c:Component, cb:Void->Void) {
        _c = c;
        var props:Dynamic = { };

        for (d in directives) {
            Reflect.setField(props, d.directive, d.value);
        }

        Actuate.tween(c, time, props, true, ValueActuator).ease(getEasing()).onComplete(cb);
    }
    
    public function stop() {
        Actuate.stop(_c);
    }

    private function getEasing():IEasing {
        return switch(easingFunction) {
            case EasingFunction.LINEAR:         Linear.easeNone;
            case EasingFunction.EASE:           Cubic.easeInOut;
            case EasingFunction.EASE_IN:        Cubic.easeIn;
            case EasingFunction.EASE_OUT:       Cubic.easeOut;
            case EasingFunction.EASE_IN_OUT:    Cubic.easeInOut;
            case _:                             Cubic.easeInOut;
        }
    }
}

#end
package haxe.ui.styles.animation.actuate;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;
import motion.Actuate;
import motion.easing.Linear;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float;
    
    public function new() {
    }
    
    public function run(c:Component, cb:Void->Void) {
        trace(">>>>>>>>>>>>>>>>>>>>> " + ValueTools.int(directives[0].value));
        var props = {
            left: ValueTools.int(directives[0].value)
        };
        Actuate.tween(c, time, props, true).ease(Linear.easeNone).onComplete(cb);
    }
}
package haxe.ui.styles.animation.none;

import haxe.ui.styles.EasingFunction;
import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float;
    public var easingFunction:EasingFunction;

    public function new() {
    }
    
    public function stop() {
        
    }
    
    public function run(c:Component, cb:Void->Void) {
        cb();
    }
}

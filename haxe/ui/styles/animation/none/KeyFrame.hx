package haxe.ui.styles.animation.none;

import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float = 0;
    public var delay:Float = 0;
    public var easingFunction:EasingFunction;

    public function new() {
    }
    
    public function stop() {
        
    }
    
    public function run(target:Dynamic, cb:Void->Void) {
        cb();
    }
}

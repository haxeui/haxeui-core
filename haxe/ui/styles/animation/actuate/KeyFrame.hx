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
    
    public function run(c:Component, cb:Void->Void) {
        //trace(">>>>>>>>>>>>>>>>>>>>> " + ValueTools.int(directives[0].value));
        
        var props:Dynamic = { };
        
        for (d in directives) {
            switch (d.value) {
                case Value.VNumber(v):
                    //Reflect.setField(props, d.directive, v);
                    Reflect.setProperty(props, d.directive, v);
                case _:    
            }
            
        }
        
        /*
        var props = {
            left: ValueTools.int(directives[0].value)
        };
        */
        trace(time + ". props: " + props);
        Actuate.tween(c, time, props, false).ease(Linear.easeNone).onComplete(cb);
    }
}

#end
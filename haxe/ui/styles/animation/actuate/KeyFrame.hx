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
        //trace(">>>>>>>>>>>>>>>>>>>>> " + ValueTools.int(directives[0].value));
        _c = c;
        var props:Dynamic = { };
        
        var color:Int = -1;
        
        for (d in directives) {
            switch (d.value) {
                case Value.VNumber(v):
                    //Reflect.setField(props, d.directive, v);
                    Reflect.setProperty(props,
                    d.directive, v);
                case Value.VColor(v):
                    //trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> " + d.directive);
                    color = v;
                    //Reflect.setProperty(props, "backgroundColor", v);
                case _:    
            }
            
        }
        
        /*
        var props = {
            left: ValueTools.int(directives[0].value)
        };
        */
        //trace(time + ". props: " + props);
        
        Actuate.tween(c, time, props, false).ease(Linear.easeNone)
        /*
            .onUpdate(function(p) {
                trace("updating - " + p);
            })
            */
            .onComplete(cb);
        if (color != -1) {
            //Actuate.transform(c, time, false).color(color);
            ColorActuator.doTween(
                c, time,
                color
            );            
            
        }
    }
    
    public function stop() {
        Actuate.stop(_c);
    }
}

#end
package haxe.ui.animation;

import haxe.ui.core.Component;

class ShakeAnimation extends Animation {
    public var direction:String;
    
    public function new(target:Component, direction:String = "horizontal") {
        super(target);
        this.direction = direction;
    }
        
    public override  function build(builder:AnimationBuilder) {
        builder.target = this.target;
        
        var horizontal:Bool = true;
        var vertical:Bool = false;
        if (direction == "both") {
            horizontal = true;
            vertical = true;
        } else if (direction == "horizontal") {
            horizontal = true;
            vertical = false;
        } else if (direction == "vertical") {
            horizontal = false;
            vertical = true;
        }
        
        if (horizontal) {
            builder.setPosition(0,   "left",  0)
                   .setPosition(20,  "left", -5)
                   .setPosition(40,  "left",  5)
                   .setPosition(60,  "left", -3)
                   .setPosition(80,  "left",  3)
                   .setPosition(100, "left",  0);
        }
        if (vertical) {
            builder.setPosition(0,   "top",  0)
                   .setPosition(20,  "top", -5)
                   .setPosition(40,  "top",  5)
                   .setPosition(60,  "top", -3)
                   .setPosition(80,  "top",  3)
                   .setPosition(100, "top",  0);
        }
    }
}
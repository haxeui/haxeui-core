package haxe.ui.animation;

import haxe.ui.core.Component;
import haxe.ui.util.Color;

class FlashAnimation extends Animation {
    public var color:Color;
    
    public function new(target:Component, color:Color = 0xffdddd) {
        super(target);
        this.color = color;
    }
    
    public override function build(builder:AnimationBuilder) {
        builder.target = this.target;
        
        var originalColor = target.backgroundColor;
        var originalColorEnd = target.backgroundColorEnd;
        
        builder.setColor(20,  "backgroundColor",    color)
               .setColor(20,  "backgroundColorEnd", color)
               .setColor(80,  "backgroundColor",    color)
               .setColor(80,  "backgroundColorEnd", color)
               .setColor(100, "backgroundColor",    originalColor)
               .setColor(100, "backgroundColorEnd", originalColorEnd);
    }
}
package haxe.ui.animation;

import haxe.ui.core.Component;
import haxe.ui.util.Color;

class FlashAnimation extends Animation {
    public var color:Color;
    public var borderColor:Color;
    
    public function new(target:Component, color:Color = 0xfde9e8, borderColor:Color = 0xf6a7a2) {
        super(target);
        this.color = color;
        this.borderColor = borderColor;
    }
    
    public override function build(builder:AnimationBuilder) {
        builder.target = this.target;
        
        var originalColor = target.backgroundColor;
        var originalColorEnd = target.backgroundColorEnd;
        var originalBorderColor = target.borderColor;
        
        builder.setColor(20,  "backgroundColor",    color)
               .setColor(20,  "backgroundColorEnd", color)
               .setColor(20,  "borderColor",        borderColor)
               .setColor(80,  "backgroundColor",    color)
               .setColor(80,  "backgroundColorEnd", color)
               .setColor(80,  "borderColor",        borderColor)
               .setColor(100, "backgroundColor",    originalColor)
               .setColor(100, "backgroundColorEnd", originalColorEnd)
               .setColor(100, "borderColor",        originalBorderColor)
               .onComplete = function() {
                    target.customStyle.backgroundColor = null;
                    target.customStyle.backgroundColorEnd = null;
                    target.borderColor = null;
               };
    }
}
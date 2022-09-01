package haxe.ui.animation;

import haxe.ui.animation.AnimationBuilder;
import haxe.ui.core.Component;
import haxe.ui.util.Color;

@:access(haxe.ui.core.Component)
class AnimationTools {
    public static function shake(c:Component, direction = "horizontal", onComplete:Void->Void = null, autoPlay:Bool = true) {
        var builder = new AnimationBuilder(c);
        builder.shake(direction);
        if (autoPlay) {
            builder.play();
        }
        return builder;
    }
    
    public static function flash(c:Component, color:Color = 0xffdddd, onComplete:Void->Void = null, autoPlay:Bool = true) {
        var builder = new AnimationBuilder(c);
        builder.flash(color);
        if (autoPlay) {
            builder.play();
        }
        return builder;
    }
}
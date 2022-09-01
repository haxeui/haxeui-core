package haxe.ui.animation;

import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.styles.Dimension;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.Value;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.elements.Directive;

@:access(haxe.ui.core.Component)
class AnimationTools {
    public static function shake(c:Component, direction = "horizontal", onComplete:Void->Void = null) {
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
        
        var k1 = new AnimationKeyFrame();
        k1.time = Value.VDimension(Dimension.PERCENT(0));
        k1.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left)));
            k1.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top)));
            k1.directives.push(directive);
        }

        var k2 = new AnimationKeyFrame();
        k2.time = Value.VDimension(Dimension.PERCENT(20));
        k2.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left - 5)));
            k2.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top - 5)));
            k2.directives.push(directive);
        }
        
        var k3 = new AnimationKeyFrame();
        k3.time = Value.VDimension(Dimension.PERCENT(40));
        k3.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left + 5)));
            k3.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top + 5)));
            k3.directives.push(directive);
        }
        
        var k4 = new AnimationKeyFrame();
        k4.time = Value.VDimension(Dimension.PERCENT(60));
        k4.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left - 3)));
            k4.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top - 3)));
            k4.directives.push(directive);
        }
        
        var k5 = new AnimationKeyFrame();
        k5.time = Value.VDimension(Dimension.PERCENT(80));
        k5.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left + 3)));
            k5.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top + 3)));
            k5.directives.push(directive);
        }

        var k6 = new AnimationKeyFrame();
        k6.time = Value.VDimension(Dimension.PERCENT(100));
        k6.directives = [];
        if (horizontal) {
            var directive = new Directive("left", Value.VDimension(Dimension.PX(c.left)));
            k6.directives.push(directive);
        }
        if (vertical) {
            var directive = new Directive("top", Value.VDimension(Dimension.PX(c.top)));
            k6.directives.push(directive);
        }
        
        var framesArray:Array<AnimationKeyFrame> = [k1, k2, k3, k4, k5, k6];
        var frames = new AnimationKeyFrames("shake", framesArray);
        c.onAnimationEnd = function(e) {
            c._componentAnimation = null;
            if (onComplete != null) {
                onComplete();
            }
        }
        Toolkit.callLater(function() {
            c.applyAnimationKeyFrame(frames, {
                duration: .1,
                easingFunction: EasingFunction.LINEAR
            });
        });
    }
}
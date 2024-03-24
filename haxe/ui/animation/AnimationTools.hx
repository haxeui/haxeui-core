package haxe.ui.animation;

import haxe.ui.animation.AnimationBuilder;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Color;

#if haxeui_expose_all
@:expose
#end
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

    public static function slideFromLeft(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideFromLeft(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentX:Float = 0;
        if (c.parentComponent != null) {
            parentX = c.parentComponent.screenLeft;
        }
        var destX = c.screenLeft - parentX;
        var originX = 0 - c.width - parentX;

        c.left = originX;

        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "left", Std.int(originX), true);
        builder.setPosition(100, "left", Std.int(destX), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }


    public static function slideToLeft(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideToLeft(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentX:Float = 0;
        if (c.parentComponent != null) {
            parentX = c.parentComponent.screenLeft;
        }
        var destX = c.screenLeft - parentX;
        var originX = 0 - c.width - parentX;

        c.left = originX;

        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "left", Std.int(destX), true);
        builder.setPosition(100, "left", Std.int(originX), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideFromTop(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideFromTop(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentY:Float = 0;
        if (c.parentComponent != null) {
            parentY = c.parentComponent.screenTop;
        }
        var destY = c.screenTop - parentY;
        var originY = 0 - c.height - parentY;

        c.top = originY;

        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "top", Std.int(originY), true);
        builder.setPosition(100, "top", Std.int(destY), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideToTop(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideToTop(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentY:Float = 0;
        if (c.parentComponent != null) {
            parentY = c.parentComponent.screenTop;
        }
        var destY = c.screenTop - parentY;
        var originY = 0 - c.height - parentY;

        c.top = originY;

        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "top", Std.int(destY), true);
        builder.setPosition(100, "top", Std.int(originY), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideFromRight(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideFromRight(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentX:Float = 0;
        if (c.parentComponent != null) {
            parentX = c.parentComponent.screenLeft;
        }
        var destX = c.screenLeft - parentX;
        var originX = (Screen.instance.width) - parentX;

        c.left = originX;
        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "left", Std.int(originX), true);
        builder.setPosition(100, "left", Std.int(destX), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideToRight(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideToRight(c, delayMs, onComplete, duration, easing);
            });
            return;
        }

        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentX:Float = 0;
        if (c.parentComponent != null) {
            parentX = c.parentComponent.screenLeft;
        }
        var destX = c.screenLeft - parentX;
        var originX = (Screen.instance.width) - parentX;

        c.left = originX;
        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "left", Std.int(destX), true);
        builder.setPosition(100, "left", Std.int(originX), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideFromBottom(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideFromBottom(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentY:Float = 0;
        if (c.parentComponent != null) {
            parentY = c.parentComponent.screenTop;
        }
        var destY = c.screenTop - parentY;
        var originY = (Screen.instance.height) - parentY;

        c.top = originY;
        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "top", Std.int(originY), true);
        builder.setPosition(100, "top", Std.int(destY), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }

    public static function slideToBottom(c:Component, delayMs:Int = 0, onComplete:Void->Void = null, duration:Float = .2, easing:String = "linear") {
        c.opacity = 0;
        if (!c.isReady) {
            c.registerEvent(UIEvent.READY, function(_) {
                slideToBottom(c, delayMs, onComplete, duration, easing);
            });
            return;
        }
        if (c.parentComponent != null) {
            c.parentComponent.validateNow();
        }
        c.validateNow();
        var parentY:Float = 0;
        if (c.parentComponent != null) {
            parentY = c.parentComponent.screenTop;
        }
        var destY = c.screenTop - parentY;
        var originY = (Screen.instance.height) - parentY;

        c.top = originY;
        var builder = new AnimationBuilder(c, duration, easing);
        builder.onComplete = onComplete;
        builder.setPosition(0, "top", Std.int(destY), true);
        builder.setPosition(100, "top", Std.int(originY), true);
        if (delayMs <= 0) {
            builder.play();
            c.opacity = 1;
        } else {
            haxe.ui.util.Timer.delay(function() {
                builder.play();
                c.opacity = 1;
            }, delayMs);
        }
    }
}
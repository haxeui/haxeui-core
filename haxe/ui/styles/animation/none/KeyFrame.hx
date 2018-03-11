package haxe.ui.styles.animation.none;

import haxe.ui.styles.animation.util.PropertyDetails;
import haxe.ui.styles.animation.util.ColorPropertyDetails;
import haxe.ui.util.StyleUtil;
import haxe.ui.util.Color;
import haxe.ui.styles.EasingFunction;
import haxe.ui.styles.elements.Directive;

class KeyFrame {
    public var directives:Array<Directive> = [];
    public var time:Float = 0;
    public var delay:Float = 0;
    public var easingFunction:EasingFunction;

    private var _callback:Void->Void;
    private var _currentTime:Float;
    private var _stopped:Bool;
    private var _target:Dynamic;
    private var _easeFunc:Float->Float;
    private var _propertyDetails:Array<PropertyDetails<Dynamic>>;
    private var _colorPropertyDetails:Array<ColorPropertyDetails<Dynamic>>;

    public function new() {
    }
    
    public function stop() {
        _stopped = true;
    }
    
    public function run(target:Dynamic, cb:Void->Void) {
        _target = target;
        _callback = cb;

        _stopped = false;
        _propertyDetails = [];
        _colorPropertyDetails = [];

        for (d in directives) {
            var componentProperty:String = StyleUtil.styleProperty2ComponentProperty(d.directive);
            var start:Dynamic = Reflect.getProperty(target, componentProperty);

            switch (d.value) {
                case Value.VColor(v):
                    var startColor:Color = cast(start, Color);
                    var endColor:Color = v;
                    var details:ColorPropertyDetails<Dynamic> = new ColorPropertyDetails (cast target,
                    componentProperty,
                    startColor,
                    endColor.r - startColor.r,
                    endColor.g - startColor.g,
                    endColor.b - startColor.b,
                    endColor.a - startColor.a
                    );
                    if (_colorPropertyDetails == null) {
                        _colorPropertyDetails = [];
                    }
                    _colorPropertyDetails.push (details);
                case _:
                    var val:Null<Float> = ValueTools.calcDimension(d.value);
                    if (val != null) {
                        var details:PropertyDetails<Dynamic> = new PropertyDetails (target, componentProperty, start, val - start);
                        _propertyDetails.push (details);
                    }
            }
        }

        _easeFunc = Ease.get(easingFunction);
        if (time == 0) {
            _apply(1);
            _finish();
        } else {
            _currentTime = Timer.stamp();

            if (delay > 0) {
                haxe.ui.util.Timer.delay(_nextFrame, Std.int(delay*1000));
            } else {
                new CallLater(_nextFrame);
            }
        }
    }

    private function _nextFrame() {
        if (_stopped == true) {
            return;
        }

        var currentTime:Float = Timer.stamp();
        var delta:Float = currentTime - _currentTime;
        if (delay < 0) {
            delta += -delay;
        }
        var tweenPosition:Float = delta / time;
        if (tweenPosition > 1) {
            tweenPosition = 1;
        }

        _apply(tweenPosition);

        if (delta >= time) {
            _finish();
        } else {
            new CallLater(_nextFrame);
        }
    }

    private function _apply(position:Float) {
        position = _easeFunc(position);
        for (details in _propertyDetails) {
            Reflect.setProperty (_target, details.propertyName, details.start + (details.change * position));
        }

        for (details in _colorPropertyDetails) {
            var currentColor:Color = Color.fromComponents(
                Std.int(details.start.r + (details.changeR * position)),
                Std.int(details.start.g + (details.changeG * position)),
                Std.int(details.start.b + (details.changeB * position)),
                Std.int(details.start.a + (details.changeA * position))
            );
            Reflect.setProperty (details.target, details.propertyName, currentColor);
        }
    }

    private function _finish() {
        _stopped = true;
        if (_callback != null) {
            new CallLater(_callback);
        }
    }
}

private class Ease {
    public static function get(easingFunction:EasingFunction):Float->Float {
        return switch(easingFunction) {
            case EasingFunction.LINEAR:
                linear;
            case EasingFunction.EASE, EasingFunction.EASE_IN_OUT:
                easeInOut;
            case EasingFunction.EASE_IN:
                easeIn;
            case EasingFunction.EASE_OUT:
                easeOut;
        }
    }

    public static function linear(k:Float):Float {
        return k;
    }

    public static function easeIn(k:Float):Float {
        return k * k * k;
    }

    public static function easeOut(k:Float):Float {
        return --k * k * k + 1;
    }

    public static function easeInOut(k:Float):Float {
        return ((k /= 1 / 2) < 1) ? 0.5 * k * k * k : 0.5 * ((k -= 2) * k * k + 2);
    }
}
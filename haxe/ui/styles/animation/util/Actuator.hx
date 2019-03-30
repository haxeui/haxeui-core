package haxe.ui.styles.animation.util;

import haxe.ui.styles.animation.util.ColorPropertyDetails;
import haxe.ui.styles.animation.util.PropertyDetails;
import haxe.ui.styles.EasingFunction;
import haxe.ui.util.Color;
import haxe.ui.util.StyleUtil;

@:structInit
class ActuatorOptions {
    @:optional public var delay:Null<Float>;
    @:optional public var easingFunction:EasingFunction;
    @:optional public var onComplete:Void->Void;
    @:optional public var onUpdate:Float->Void;
}

class Actuator<T> {
    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    public static function tween<T>(target:T, properties:Dynamic, duration:Float, ?options:ActuatorOptions):Actuator<T> {
        var actuator = new Actuator<T>(target, properties, duration, options);
        actuator.run();
        return actuator;
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    /**
     The object to apply the tween.
    **/
    public var target(default, null):T;

    /**
     End values to apply to the target.
    **/
    public var properties(default, null):Dynamic;

    /**
     Defines how long time an animation should take to complete.
    **/
    public var duration(default, null):Float = 0;

    /**
     Specifies a delay for the start of an animation in seconds. If using negative values, the animation will start as if it
     had already been playing for N seconds.
    **/
    public var delay(default, null):Float = 0;

    public function new(target:T, properties:Dynamic, duration:Float, ?options:ActuatorOptions) {
        this.target = target;
        this.properties = properties;
        this.duration = duration;

        if (options != null) {
            _easeFunc = Ease.get((options.easingFunction != null) ? options.easingFunction : EasingFunction.EASE);

            if (options.delay != null)          delay = options.delay;
            if (options.onComplete != null)     _onComplete = options.onComplete;
            if (options.onUpdate != null)       _onUpdate = options.onUpdate;
        }
    }

    /**
     Stops the tween if it is running.
    **/
    public function stop() {
        _stopped = true;
    }

    /**
     Starts to run the tween.
    **/
    public function run() {
        _initialize();

        _stopped = false;

        if (duration == 0) {
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

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private var _currentTime:Float;
    private var _easeFunc:Float->Float;
    private var _onComplete:Void->Void;
    private var _onUpdate:Float->Void;
    private var _stopped:Bool;

    private var _propertyDetails:Array<PropertyDetails<T>>;
    private var _colorPropertyDetails:Array<ColorPropertyDetails<T>>;

    private function _initialize() {
        _propertyDetails = [];
        _colorPropertyDetails = [];

        for (p in Reflect.fields(properties)) {
            var componentProperty:String = StyleUtil.styleProperty2ComponentProperty(p);
            var start:Dynamic = Reflect.getProperty(target, componentProperty);
            var end:Dynamic = Reflect.getProperty(properties, p);
            if (start == null || end == null) {
                continue;
            }
            switch (end) {
                case Value.VColor(v):
                    var startColor:Color = cast(start, Color);
                    var endColor:Color = v;
                    var details:ColorPropertyDetails<T> = new ColorPropertyDetails(target,
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
                    var val:Null<Float> = ValueTools.calcDimension(end);
                    if (val != null) {
                        var details:PropertyDetails<T> = new PropertyDetails(target, componentProperty, start, val - start);
                        _propertyDetails.push (details);
                    }
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
        var tweenPosition:Float = delta / duration;
        if (tweenPosition > 1) {
            tweenPosition = 1;
        }

        _apply(tweenPosition);

        if (_onUpdate != null) {
            _onUpdate(currentTime);
        }

        if (delta >= duration) {
            _finish();
        } else {
            new CallLater(_nextFrame);
        }
    }

    private function _apply(position:Float) {
        position = _easeFunc(position);
        for (details in _propertyDetails) {
            Reflect.setProperty (target, details.propertyName, details.start + (details.change * position));
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
        if (_onComplete != null) {
            _onComplete();
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
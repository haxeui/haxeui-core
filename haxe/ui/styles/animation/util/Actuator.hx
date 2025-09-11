package haxe.ui.styles.animation.util;

import haxe.ui.core.Component;
import haxe.ui.core.TypeMap;
import haxe.ui.styles.EasingFunction;
import haxe.ui.util.Color;
import haxe.ui.util.MathUtil;
import haxe.ui.util.StringUtil;
import haxe.ui.util.StyleUtil;
import haxe.ui.util.Variant.VariantType;
import haxe.ui.util.Variant;

@:structInit
class ActuatorOptions {
    @:optional public var delay:Null<Float>;
    @:optional public var easingFunction:EasingFunction;
    @:optional public var onComplete:Void->Void;
    @:optional public var onUpdate:Float->Float->Float->Void;
}

class Actuator<T> {
    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    public static function tween<T>(target:T, properties:Dynamic, duration:Float, options:ActuatorOptions = null):Actuator<T> {
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

    public function new(target:T, properties:Dynamic, duration:Float, options:ActuatorOptions = null) {
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
        target = null;
    }

    /**
     Starts to run the tween.
    **/
    public function run() {
        _initialize();

        _stopped = false;

        if ((target is Component) && cast(target, Component).animatable == false) {
            duration = 0;
        }

        if (duration == 0) {
            _apply(1);
            _finish();
        } else {
            _currentTime = MathUtil.round(Timer.stamp(), 2); // we want to round the start time to account for small differences

            if (delay > 0) {
                haxe.ui.util.Timer.delay(function() {
                    registerFrameCallback(_nextFrame);
                }, Std.int(delay * 1000));
            } else {
                registerFrameCallback(_nextFrame);
            }
        }
    }

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private var _currentTime:Float;
    private var _easeFunc:Float->Float;
    private var _onComplete:Void->Void;
    private var _onUpdate:Float->Float->Float->Void;
    private var _stopped:Bool;

    private var _propertyDetails:Array<PropertyDetails<T>>;
    private var _colorPropertyDetails:Array<ColorPropertyDetails<T>>;
    private var _stringPropertyDetails:Array<StringPropertyDetails<T>>;

    private function _initialize() {
        if (_isValid() == false) {
            stop();
            return;
        }
        
        _propertyDetails = [];
        _colorPropertyDetails = [];
        _stringPropertyDetails = [];

        for (p in Reflect.fields(properties)) {
            var componentProperty:String = StyleUtil.styleProperty2ComponentProperty(p);

            var end:Dynamic = Reflect.getProperty(properties, p);
            switch (end) {
                case Value.VDimension(Dimension.PERCENT(v)):
                    componentProperty = "percent" + StringUtil.capitalizeFirstLetter(componentProperty);
                case _:
            }

            var start:Dynamic = Reflect.getProperty(target, componentProperty);
            if (start == null) {
                switch (end) {
                    case Value.VDimension(Dimension.PERCENT(v)) | Value.VNumber(v):
                        start = 0;
                    case Value.VString(v):
                        start = v;
                    case _:
                }
            }

            var isVariant = false;
            if (start != null) {
                try { // some neko strangness here with exception being thrown on the switch
                    switch (start) {
                        case VariantType.VT_String(v):
                            start = v;
                            isVariant = true;
                        case _:
                    }
                } catch (e:Dynamic) { }
            }

            if (end != null) {
                try { // some neko strangness here with exception being thrown on the switch
                    switch (end) {
                        case VariantType.VT_String(v):
                            end = v;
                            isVariant = true;
                        case _:
                    }
                } catch (e:Dynamic) { }
            }

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
                case Value.VDimension(Dimension.PERCENT(v)):
                    var val:Null<Float> = v;
                    if (val != null) {
                        var details:PropertyDetails<T> = new PropertyDetails(target, componentProperty, start, val - start);
                        _propertyDetails.push (details);
                    }

                case Value.VString(v):

                    var startVal:String = start;
                    var endVal:String = ValueTools.string(end);
                    if (endVal.indexOf("[[") != -1) {
                        var n1 = endVal.indexOf("[[");
                        var n2 = endVal.indexOf("]]") + 2;
                        var before = endVal.substr(0, n1);
                        var after = endVal.substr(n2);

                        // lets find out where we are
                        var s = StringTools.replace(startVal, before, "");
                        s = StringTools.replace(s, after, "");
                        var startInt = Std.parseInt(s);

                        var s = StringTools.replace(endVal, before + "[[", "");
                        s = StringTools.replace(s, "]]" + after, "");
                        var endInt = Std.parseInt(s);

                        var details:StringPropertyDetails<T> = new StringPropertyDetails(target, componentProperty, startVal, endVal);
                        details.pattern = before + "[[n]]" + after;
                        details.startInt = startInt;
                        details.changeInt = endInt - startInt;
                        var typeInfo = TypeMap.getTypeInfo(Type.getClassName(Type.getClass(target)), componentProperty);
                        if (typeInfo != null && isVariant == false && typeInfo == "Variant") {
                            isVariant = true;
                        }
                        details.isVariant = isVariant;
                        _stringPropertyDetails.push(details);
                    } else {
                        var details:StringPropertyDetails<T> = new StringPropertyDetails(target, componentProperty, startVal, endVal);
                        _stringPropertyDetails.push(details);
                    }
                case _:
                    var val:Null<Float> = ValueTools.calcDimension(end);
                    if (val != null) {
                        var details:PropertyDetails<T> = new PropertyDetails(target, componentProperty, start, val - start);
                        _propertyDetails.push(details);
                    } else {
                        var details:PropertyDetails<T> = new PropertyDetails(target, componentProperty, start, end - start);
                        _propertyDetails.push (details);
                    }
            }
        }
    }

    private function _nextFrame(stamp:Float) {
        if (_stopped == true) {
            return;
        }

        var currentTime:Float = stamp;
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
            _onUpdate(currentTime, delta, tweenPosition);
        }

        if (delta >= duration) {
            _finish();
        }
    }

    private function _isValid() {
        if (target == null) {
            return false;
        }
        
        if ((target is Component)) {
            var c:Component = cast target;
            if (@:privateAccess c._isDisposed == true) {
                return false;
            }
        }
        
        return true;
    }
    
    private function _apply(position:Float) {
        if (_isValid() == false) {
            stop();
            return;
        }
        
        position = _easeFunc(position);
        for (details in _propertyDetails) {
            var newPos = details.start + (details.change * position);
            #if haxeui_hxwidgets
            // the actuator can flood haxeui-hxwidgets (and therefore wxWidgets) with far too many changes
            // than wx (and presumably the OS) can handle, this slows that down by detecting values that are
            // the same (rounded since wx only deals with ints anyway) and when they are the same adding
            // a tiny sleep to stop the event queue getting flooded
            newPos = Math.round(newPos);
            if (details.lastValue != null && details.lastValue == newPos) {
                Sys.sleep(.001);
                continue;
            }
            #end
            Reflect.setProperty(target, details.propertyName, newPos);
            details.lastValue = newPos;
        }

        for (details in _stringPropertyDetails) {
            if (details.pattern != null) {
                var newInt = Std.int(details.startInt + (position * details.changeInt));
                var newString = StringTools.replace(details.pattern, "[[n]]", "" + newInt);
                if (details.isVariant) {
                    var v:Variant = newString;
                    Reflect.setProperty(target, details.propertyName, v);
                } else {
                    Reflect.setProperty(target, details.propertyName, newString);
                }
            } else {
                if (position != 1) {
                    Reflect.setProperty(target, details.propertyName, details.start);
                } else {
                    Reflect.setProperty(target, details.propertyName, details.end);
                }
            }
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
        target = null;
        unregisterFrameCallback(_nextFrame);
        if (_onComplete != null) {
            _onComplete();
        }
    }

    // we want to unify animation "ticks" by having a single set of callbacks that are all called at the same time
    // (once per frame event - via calllater)
    private static var frameCallbacks:Array<Float->Void> = [];
    private static var dispatchingFrameCallbacks:Bool = false;
    private static function registerFrameCallback(fn:Float->Void) {
        frameCallbacks.push(fn);
        if (dispatchingFrameCallbacks == false) {
            dispatchingFrameCallbacks = true;
            processCallbacks();
        }
    }
    
    private static function unregisterFrameCallback(fn:Float->Void) {
        new CallLater(function () {
            frameCallbacks.remove(fn);
            if (frameCallbacks.length == 0) {
                dispatchingFrameCallbacks = false;
            }
        });
    }


    private static function processCallbacks() {
        if (dispatchingFrameCallbacks == false) {
            return;
        }

        new CallLater(function() {
            var stamp = Timer.stamp();
            for (cb in frameCallbacks) {
                //s.frame();
                cb(stamp);
            }

            processCallbacks();
        });
    }
}

private class Ease {
    public static function get(easingFunction:EasingFunction):Float->Float {
        return switch (easingFunction) {
            case EasingFunction.LINEAR:
                linear;
		  case EasingFunction.QUAD_IN:
		      quadIn;
		  case EasingFunction.QUAD_OUT:
			 quadOut;
		  case EasingFunction.QUAD_IN_OUT:
		      quadInOut;
            case EasingFunction.EASE, EasingFunction.EASE_IN_OUT, EasingFunction.CUBIC_IN_OUT:
                cubicInOut;
            case EasingFunction.EASE_IN, EasingFunction.CUBIC_IN:
                cubicIn;
            case EasingFunction.EASE_OUT, EasingFunction.CUBIC_OUT:
                cubicOut;
		  case EasingFunction.QUART_IN:
		      quartIn;
		  case EasingFunction.QUART_OUT:
		      quartOut;
		  case EasingFunction.QUART_IN_OUT:
		      quartInOut;
        }
    }

    public static function linear(k:Float):Float {
        return k;
    }
    
    public static function quadIn(k:Float):Float {
	   return k * k;
    }
    
    public static function quadOut(k:Float):Float {
	   return -k * (k - 2);
    }
    
    public static function quadInOut(k:Float):Float {
	   return k <= .5 ? k * k * 2 : 1 - (--k) * k * 2;
    }

    public static function cubicIn(k:Float):Float {
        return k * k * k;
    }

    public static function cubicOut(k:Float):Float {
        return --k * k * k + 1;
    }

    public static function cubicInOut(k:Float):Float {
        return ((k /= 1 / 2) < 1) ? 0.5 * k * k * k : 0.5 * ((k -= 2) * k * k + 2);
    }

    public static function quartIn(k:Float):Float {
        return k * k * k * k;
    }

    public static function quartOut(k:Float):Float {
        return 1 - (k -= 1) * k * k * k;
    }

    public static function quartInOut(k:Float):Float {
        return k <= .5 ? k * k * k * k * 8 : (1 - (k = k * 2 - 2) * k * k * k) / 2 + .5;
    }
}
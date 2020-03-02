package haxe.ui.styles.animation.util;

import haxe.ui.core.Component;
import haxe.ui.styles.animation.util.ColorPropertyDetails;
import haxe.ui.styles.animation.util.PropertyDetails;
import haxe.ui.styles.EasingFunction;
import haxe.ui.util.Color;
import haxe.ui.util.StringUtil;
import haxe.ui.util.StyleUtil;
import haxe.ui.styles.Style2;

@:structInit
class ActuatorOptions {
    @:optional public var delay:Null<Float>;
    @:optional public var easingFunction:EasingFunction;
    @:optional public var onComplete:Void->Void;
    @:optional public var onUpdate:Float->Void;
}

typedef AnimatingColorBlock = {
    @:optional var index:Int;
    var deltaR:Int;
    var deltaG:Int;
    var deltaB:Int;
    var deltaA:Int;
    var start:Color;
}

typedef AnimatingBorderColors = {
    @:optional var left:AnimatingColorBlock;
    @:optional var top:AnimatingColorBlock;
    @:optional var bottom:AnimatingColorBlock;
    @:optional var right:AnimatingColorBlock;
}

class Actuator<T> {
    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    public static function tween<T>(target:T, properties:Dynamic, style:Style2, duration:Float, ?options:ActuatorOptions):Actuator<T> {
        var actuator = new Actuator<T>(target, properties, style, duration, options);
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
    public var style(default, null):Style2;

    /**
     Defines how long time an animation should take to complete.
    **/
    public var duration(default, null):Float = 0;

    /**
     Specifies a delay for the start of an animation in seconds. If using negative values, the animation will start as if it
     had already been playing for N seconds.
    **/
    public var delay(default, null):Float = 0;

    public function new(target:T, properties:Dynamic, style:Style2, duration:Float, ?options:ActuatorOptions) {
        this.target = target;
        this.properties = properties;
        this.style = style;
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
        _initialize2();

        _stopped = false;

        if (duration == 0) {
            trace("ANIMATION DURATION IS ZERO!");
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

    private var _tempPropertyDetailsForBackgroundColors:Array<PropertyDetails<T>>;
    
    private var _frames:Array<ActuatorFrame>;
    
    
    private var _backgroundColorsDetails:Array<AnimatingColorBlock>;
    private var _borderColorDetails:AnimatingBorderColors;
    private var _startStyle:Style2;
    private var _styleDiff:Style2;
    
    private function _initialize2() {
        _tempPropertyDetailsForBackgroundColors = [];
        
        _backgroundColorsDetails = [];
        _borderColorDetails = {};
        
        if (style.backgroundColors != null) {
            
        }
        
        var c = cast(target, Component);
        _startStyle = {};
        StyleUtils.mergeStyle(_startStyle, c.computedStyle);
        
        
        
        
        
        
        
        
        if (style.width != null) {
            if (c.percentWidth != null) {
                _startStyle.width = percent(c.percentWidth);
            } else if (c.width != null) {
                _startStyle.width = pixels(c.width);
            }
        }
        
        if (style.height != null) {
            if (c.percentHeight != null) {
                _startStyle.height = percent(c.percentHeight);
            } else if (c.height != null) {
                _startStyle.height = pixels(c.height);
            }
        }
        
        
        trace("start style: " + _startStyle);
        trace("end style: " + style);
//return;        
        
        
        _styleDiff = StyleUtils.diffStyle(style, _startStyle);
      
        
        trace("diff style: " + _styleDiff);
        
        
        
        
        
        var lastEndCol = null;
        if (_styleDiff.backgroundColors != null) {
            trace("ANIMATE BG COLORUS");
            var startArray:Array<StyleColorBlock> = c.computedStyle.backgroundColors;
            var endArray:Array<StyleColorBlock> = style.backgroundColors;
            for (i in 0...startArray.length) {
                var startCol = startArray[i];
                var endCol = endArray[i];
                if (endCol == null) {
                    if (lastEndCol != null) {
                        endCol = lastEndCol;
                    } else {
                        endCol = startCol;
                    }
                }
                var details:AnimatingColorBlock = {
                    index: i,
                    start: startCol.color,
                    deltaR: (endCol.color.r - startCol.color.r),
                    deltaG: (endCol.color.g - startCol.color.g),
                    deltaB: (endCol.color.b - startCol.color.b),
                    deltaA: (endCol.color.a - startCol.color.a)
                }
                _backgroundColorsDetails.push(details);
                lastEndCol = endCol;
            }
        }
        
        if (_styleDiff.width != null) {
            trace("ANIMATE WIDTH IS - " + _styleDiff.width);
        }
        
        if (_styleDiff.padding != null && _styleDiff.padding.isNull == false) {
            trace("ANIMATE PADDING!!!");
        }
        
        if (_styleDiff.border != null && _styleDiff.border.isNull == false) {
            if (_styleDiff.border.left != null && _styleDiff.border.left.isNull == false) {
                if (_styleDiff.border.left.color != null) {
                    var startCol = _startStyle.border.left;
                    var endCol = style.border.left;
                    _borderColorDetails.left = {
                        start: startCol.color,
                        deltaR: (endCol.color.r - startCol.color.r),
                        deltaG: (endCol.color.g - startCol.color.g),
                        deltaB: (endCol.color.b - startCol.color.b),
                        deltaA: (endCol.color.a - startCol.color.a)
                    }
                }
            }
            
            if (_styleDiff.border.top != null && _styleDiff.border.top.isNull == false) {
                if (_styleDiff.border.top.color != null) {
                    var startCol = _startStyle.border.top;
                    var endCol = style.border.top;
                    _borderColorDetails.top = {
                        start: startCol.color,
                        deltaR: (endCol.color.r - startCol.color.r),
                        deltaG: (endCol.color.g - startCol.color.g),
                        deltaB: (endCol.color.b - startCol.color.b),
                        deltaA: (endCol.color.a - startCol.color.a)
                    }
                }
            }
            
            if (_styleDiff.border.bottom != null && _styleDiff.border.bottom.isNull == false) {
                if (_styleDiff.border.bottom.color != null) {
                    var startCol = _startStyle.border.bottom;
                    var endCol = style.border.bottom;
                    _borderColorDetails.bottom = {
                        start: startCol.color,
                        deltaR: (endCol.color.r - startCol.color.r),
                        deltaG: (endCol.color.g - startCol.color.g),
                        deltaB: (endCol.color.b - startCol.color.b),
                        deltaA: (endCol.color.a - startCol.color.a)
                    }
                }
            }
            
            if (_styleDiff.border.right != null && _styleDiff.border.right.isNull == false) {
                if (_styleDiff.border.right.color != null) {
                    var startCol = _startStyle.border.right;
                    var endCol = style.border.right;
                    _borderColorDetails.right = {
                        start: startCol.color,
                        deltaR: (endCol.color.r - startCol.color.r),
                        deltaG: (endCol.color.g - startCol.color.g),
                        deltaB: (endCol.color.b - startCol.color.b),
                        deltaA: (endCol.color.a - startCol.color.a)
                    }
                }
            }
        }
        
        /*
        trace("init 2 - " + style);
        if (style.backgroundColors != null) {
            var array:Array<StyleColorBlock> = style.backgroundColors;
            if (array.length > 0) {
                trace("WE HAVE SOME BG COLOURS!");
                var i = 0;
                for (a in array) {
                    var c = cast(target, Component);
                    var currentArray:Array<StyleColorBlock> = c.computedStyle.backgroundColors;
                    var current = currentArray[0];
                    trace("current: " + current);
                    var details:PropertyDetails<T> = new PropertyDetails(target, "bob", current.color, a.color - current.color);
                    _tempPropertyDetailsForBackgroundColors.push(details);
                    i++;
                }
            }
        }
        */
    }
    
    private function _initialize() {
        _propertyDetails = [];
        _colorPropertyDetails = [];

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
                    case Value.VDimension(Dimension.PERCENT(v)):
                        start = 0;
                    case _:
                }
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
        /*
        trace("applying: " + position);
        for (details in _propertyDetails) {
            trace("setting: " + details.propertyName);
            Reflect.setProperty(target, details.propertyName, details.start + (details.change * position));
        }

        for (details in _colorPropertyDetails) {
            var currentColor:Color = Color.fromComponents(
                Std.int(details.start.r + (details.changeR * position)),
                Std.int(details.start.g + (details.changeG * position)),
                Std.int(details.start.b + (details.changeB * position)),
                Std.int(details.start.a + (details.changeA * position))
            );
            trace("setting: " + details.propertyName);
            Reflect.setProperty (details.target, details.propertyName, currentColor);
        }
        */

        var c = cast(target, Component);
        //if (c.animatingStyle == null) {
            c.animatingStyle = {};
        //}
        
        var invalidate:Bool = false;
        for (details in _backgroundColorsDetails) {
            if (c.animatingStyle.backgroundColors == null) {
                c.animatingStyle.backgroundColors = [];
            }
            var array:Array<StyleColorBlock> = c.animatingStyle.backgroundColors;
            if (array.length <= details.index) {
                array.push({color: 0});
            }
            
            var currentColor:Color = Color.fromComponents(
                Std.int(details.start.r + (details.deltaR * position)),
                Std.int(details.start.g + (details.deltaG * position)),
                Std.int(details.start.b + (details.deltaB * position)),
                Std.int(details.start.a + (details.deltaA * position))
            );
            array[details.index].color = currentColor;
            invalidate = true;
        }

        if (_styleDiff.width != null) {
            switch [_startStyle.width, _styleDiff.width] {
                case [pixels(v1), pixels(v2)]:
                    c.animatingStyle.width = pixels(v1 + (v2 * position));
                case [percent(v1), percent(v2)]:
                    c.animatingStyle.width = percent(v1 + (v2 * position));
                case _:
            }
            invalidate = true;
        }

        if (_styleDiff.height != null) {
            switch [_startStyle.height, _styleDiff.height] {
                case [pixels(v1), pixels(v2)]:
                    c.animatingStyle.height = pixels(v1 + (v2 * position));
                case [percent(v1), percent(v2)]:
                    c.animatingStyle.height = percent(v1 + (v2 * position));
                case _:
            }
            invalidate = true;
        }
        
        if (_styleDiff.padding != null && _styleDiff.padding.isNull == false) {
            if (_styleDiff.padding.left != null) {
                var start:Float = _startStyle.padding.left;
                var diff:Float = _styleDiff.padding.left;
                c.animatingStyle.padding.left = start + (diff * position);
                invalidate = true;
            }
            if (_styleDiff.padding.top != null) {
                var start:Float = _startStyle.padding.top;
                var diff:Float = _styleDiff.padding.top;
                c.animatingStyle.padding.top = start + (diff * position);
                invalidate = true;
            }
            if (_styleDiff.padding.bottom != null) {
                var start:Float = _startStyle.padding.bottom;
                var diff:Float = _styleDiff.padding.bottom;
                c.animatingStyle.padding.bottom = start + (diff * position);
                invalidate = true;
            }
            if (_styleDiff.padding.right != null) {
                var start:Float = _startStyle.padding.right;
                var diff:Float = _styleDiff.padding.right;
                c.animatingStyle.padding.right = start + (diff * position);
                invalidate = true;
            }
        }
        
        if (_styleDiff.border != null && _styleDiff.border.isNull == false) {
            if (_styleDiff.border.left != null && _styleDiff.border.left.isNull == false) {
                if (_styleDiff.border.left.width != null) {
                    var start:Float = _startStyle.border.left.width;
                    var diff:Float = _styleDiff.border.left.width;
                    c.animatingStyle.border.left.width = start + (diff * position);
                    invalidate = true;
                }
                if (_borderColorDetails.left != null) {
                    var currentColor:Color = Color.fromComponents(
                        Std.int(_borderColorDetails.left.start.r + (_borderColorDetails.left.deltaR * position)),
                        Std.int(_borderColorDetails.left.start.g + (_borderColorDetails.left.deltaG * position)),
                        Std.int(_borderColorDetails.left.start.b + (_borderColorDetails.left.deltaB * position)),
                        Std.int(_borderColorDetails.left.start.a + (_borderColorDetails.left.deltaA * position))
                    );
                    c.animatingStyle.border.left.color = currentColor;
                    invalidate = true;
                }
            }
            
            if (_styleDiff.border.top != null && _styleDiff.border.top.isNull == false) {
                if (_styleDiff.border.top.width != null) {
                    var start:Float = _startStyle.border.top.width;
                    var diff:Float = _styleDiff.border.top.width;
                    c.animatingStyle.border.top.width = start + (diff * position);
                    invalidate = true;
                }
                if (_borderColorDetails.top != null) {
                    var currentColor:Color = Color.fromComponents(
                        Std.int(_borderColorDetails.top.start.r + (_borderColorDetails.top.deltaR * position)),
                        Std.int(_borderColorDetails.top.start.g + (_borderColorDetails.top.deltaG * position)),
                        Std.int(_borderColorDetails.top.start.b + (_borderColorDetails.top.deltaB * position)),
                        Std.int(_borderColorDetails.top.start.a + (_borderColorDetails.top.deltaA * position))
                    );
                    c.animatingStyle.border.top.color = currentColor;
                    invalidate = true;
                }
            }
            
            if (_styleDiff.border.bottom != null && _styleDiff.border.bottom.isNull == false) {
                if (_styleDiff.border.bottom.width != null) {
                    var start:Float = _startStyle.border.bottom.width;
                    var diff:Float = _styleDiff.border.bottom.width;
                    c.animatingStyle.border.bottom.width = start + (diff * position);
                    invalidate = true;
                }
                if (_borderColorDetails.bottom != null) {
                    var currentColor:Color = Color.fromComponents(
                        Std.int(_borderColorDetails.bottom.start.r + (_borderColorDetails.bottom.deltaR * position)),
                        Std.int(_borderColorDetails.bottom.start.g + (_borderColorDetails.bottom.deltaG * position)),
                        Std.int(_borderColorDetails.bottom.start.b + (_borderColorDetails.bottom.deltaB * position)),
                        Std.int(_borderColorDetails.bottom.start.a + (_borderColorDetails.bottom.deltaA * position))
                    );
                    c.animatingStyle.border.bottom.color = currentColor;
                    invalidate = true;
                }
            }
            
            if (_styleDiff.border.right != null && _styleDiff.border.right.isNull == false) {
                if (_styleDiff.border.right.width != null) {
                    var start:Float = _startStyle.border.right.width;
                    var diff:Float = _styleDiff.border.right.width;
                    c.animatingStyle.border.right.width = start + (diff * position);
                    invalidate = true;
                }
                if (_borderColorDetails.right != null) {
                    var currentColor:Color = Color.fromComponents(
                        Std.int(_borderColorDetails.right.start.r + (_borderColorDetails.right.deltaR * position)),
                        Std.int(_borderColorDetails.right.start.g + (_borderColorDetails.right.deltaG * position)),
                        Std.int(_borderColorDetails.right.start.b + (_borderColorDetails.right.deltaB * position)),
                        Std.int(_borderColorDetails.right.start.a + (_borderColorDetails.right.deltaA * position))
                    );
                    c.animatingStyle.border.right.color = currentColor;
                    invalidate = true;
                }
            }
            
            if (_styleDiff.border.radius != null) {
                var start:Float = _startStyle.border.radius;
                var diff:Float = _styleDiff.border.radius;
                c.animatingStyle.border.radius = start + (diff * position);
                invalidate = true;
            }
        }
        
        if (invalidate == true) {
            c.invalidateComponentStyle();
        }
        /*
        var c = cast(target, Component);
        var c = cast(target, Component);
        var c = cast(target, Component);
        for (details in _tempPropertyDetailsForBackgroundColors) {
            trace("setting2 " + details.propertyName + ", " + (details.start + (details.change * position)));
            if (c.animatingStyle == null) {
                c.animatingStyle = {};
            }
            if (c.animatingStyle.backgroundColors == null) {
                c.animatingStyle.backgroundColors = [];
            }
            var array:Array<StyleColorBlock> = c.animatingStyle.backgroundColors;
            if (array.length == 0) {
                array.push({color: 0});
            }
            array[0].color = Std.int(details.start + (details.change * position));
        }

        c.invalidateComponentStyle();
        */
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
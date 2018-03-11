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
    public var delay:Float = 0;                 //TODO - to be implemented
    public var easingFunction:EasingFunction;   //TODO - to be implemented

    private var _callback:Void->Void;
    private var _currentTime:Float;
    private var _stopped:Bool;
    private var _target:Dynamic;
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

        if (time == 0) {
            _apply(1);
            _finish();
        } else {
            _currentTime = Timer.stamp();

            new CallLater(_nextFrame);
        }
    }

    private function _nextFrame() {
        if (_stopped == true) {
            return;
        }

        var currentTime:Float = Timer.stamp();
        var delta:Float = currentTime - _currentTime;
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

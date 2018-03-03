package haxe.ui.styles.animation.actuate;

import haxe.ui.util.StyleUtil;
import motion.actuators.PropertyDetails;
import haxe.ui.util.Color;
import motion.actuators.SimpleActuator;

class ValueActuator<T> extends SimpleActuator<T, Dynamic> {
    private var colorPropertyDetails:Array<ColorPropertyDetails<Dynamic>>;

    public function new(target : T, duration : Float, properties : Dynamic) {
        super(target, duration, properties);
    }

    override private function apply ():Void {
        for (p in Reflect.fields (properties)) {
            var value:Dynamic = Reflect.getProperty(properties, p);
            switch (value) {
                case Value.VColor(v):
                    value = v;
                case _:
                    value = ValueTools.calcDimension(value);
            }

            Reflect.setProperty (target, p, value);
        }
    }

    override private function initialize() : Void {
        for (p in Reflect.fields(properties)) {
            var componentProperty:String = StyleUtil.styleProperty2ComponentProperty(p);
            var start:Dynamic = Reflect.getProperty(target, componentProperty);
            var value:Dynamic = Reflect.getProperty(properties, p);

            switch (value) {
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
                    if (colorPropertyDetails == null) {
                        colorPropertyDetails = [];
                    }
                    colorPropertyDetails.push (details);
                case _:
                    var val:Null<Float> = ValueTools.calcDimension(value);
                    if (val != null) {
                        var details:PropertyDetails<Dynamic> = new PropertyDetails (cast target, componentProperty, start, val - start, false);
                        propertyDetails.push (details);
                    }
            }
        }

        detailsLength = propertyDetails.length;
        initialized = true;
    }

    override private function update(currentTime : Float) : Void {
        if (!paused) {
            if (!initialized) {
                initialize ();
            }

            if (colorPropertyDetails != null) {
                var tweenPosition:Float = (currentTime - timeOffset) / duration;
                if (tweenPosition > 1) {
                    tweenPosition = 1;
                }

                var easing:Float;
                if (!special) {
                    easing = _ease.calculate (tweenPosition);
                } else {
                    easing = _ease.calculate (1 - tweenPosition);
                }

                for (details in colorPropertyDetails) {
                    var currentColor:Color = Color.fromComponents(
                        Std.int(details.start.r + (details.changeR * easing)),
                        Std.int(details.start.g + (details.changeG * easing)),
                        Std.int(details.start.b + (details.changeB * easing)),
                        Std.int(details.start.a + (details.changeA * easing))
                    );
                    Reflect.setProperty (details.target, details.propertyName, currentColor);
                }
            }

            super.update(currentTime);
        }
    }
}

private class ColorPropertyDetails<T> {
    public var changeR:Int;
    public var changeG:Int;
    public var changeB:Int;
    public var changeA:Int;
    public var propertyName:String;
    public var start:Color;
    public var target:T;

    public function new (target:T, propertyName:String, start:Color, changeR:Int, changeG:Int, changeB:Int, changeA:Int):Void {
        this.target = target;
        this.propertyName = propertyName;
        this.start = start;
        this.changeR = changeR;
        this.changeG = changeG;
        this.changeB = changeB;
        this.changeA = changeA;
    }
}
package haxe.ui.styles.animation.actuate;

import haxe.ui.core.Component;
import motion.Actuate;
import motion.actuators.IGenericActuator;
import motion.actuators.PropertyDetails;
import motion.actuators.SimpleActuator;

class ColorActuator<T> extends SimpleActuator<T, ColorActuator<T>> {
    private var startRed : Float;
    private var startGreen : Float;
    private var startBlue : Float;
    private var endRed : Float;
    private var endGreen : Float;
    private var endBlue : Float;

    public var colorPosition : Float;

    public function new(target : T, duration : Float, properties : Dynamic) {
        super(target, duration, properties);
    }

    override public function apply() : Void {
        //initialize();
        setField(target, "backgroundColor", ((Std.int(endRed) << 16) | (Std.int(endGreen) << 8) | Std.int(endBlue)));
    }

    override private function initialize() : Void {
        var targetColor = getField(target, "backgroundColor");

        startRed = ((targetColor >> 16) & 0xFF);
        startGreen = ((targetColor >> 8) & 0xFF);
        startBlue = (targetColor & 0xFF);

        endRed = ((properties.color >> 16) & 0xFF);
        endGreen = ((properties.color >> 8) & 0xFF);
        endBlue = (properties.color & 0xFF);

        propertyDetails.push(new PropertyDetails(this, "colorPosition", 0.0, 1.0));

        detailsLength = propertyDetails.length;
        initialized = true;
    }

    override private function update(currentTime : Float) : Void {
        super.update(currentTime);

        var tweenPosition:Float = (currentTime - timeOffset) / duration;
        if (tweenPosition > 1) {
            tweenPosition = 1;
        }
        
        //trace("tweenPosition: " + tweenPosition);
        
        /*
        var invColorPosition = 1.0 - colorPosition;
        var red = startRed * invColorPosition + endRed * colorPosition;
        var green = startGreen * invColorPosition + endGreen * colorPosition;
        var blue = startBlue * invColorPosition + endBlue * colorPosition;
        */

        var invColorPosition = 1.0 - tweenPosition;
        var red = startRed * invColorPosition + endRed * tweenPosition;
        var green = startGreen * invColorPosition + endGreen * tweenPosition;
        var blue = startBlue * invColorPosition + endBlue * tweenPosition;
        
        var s:String = "#" + StringTools.hex(((Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue)), 6);
        trace(s);
        
        setField(target, "backgroundColor", ((Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue)));
        //setField(target, "styleString", "background-color: " + s);
        
        //cast(target, Component).backgroundColor = ((Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue));
        //cast(target, Component).animatedStyle.backgroundColor = ((Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue));
        //cast(target, Component).invalidateStyle();
        //cast(target, Component).validateStyle2();
        //cast(target, Component).invalidateDisplay();
        
        //cast(target, Component).bg = ((Std.int(red) << 16) | (Std.int(green) << 8) | Std.int(blue));
    }

    public static function doApply<T>(target : T, color : Int) : IGenericActuator {
        return Actuate.apply(target, { color : color }, ColorActuator);
    }

    public static function doTween<T>(target : T, duration : Float, color : Int, overwrite : Bool = true) : IGenericActuator {
        return Actuate.tween(target, duration, { color : color }, overwrite, ColorActuator);
    }
}
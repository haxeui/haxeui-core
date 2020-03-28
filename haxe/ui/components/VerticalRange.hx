package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

@:composite(VerticalRangeLayout)
class VerticalRange extends Range {
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(VerticalRangePosFromCoord)         private override function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class VerticalRangePosFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var range = cast(_component, Range);
        var p = cast(pos, Point);
        var ypos = p.y - range.layout.paddingTop;
        var ucy = range.layout.usableHeight;
        if (ypos >= ucy) {
            ypos = ucy;
        }
        
        var m:Float = range.max - range.min;
        var d = (ucy / m);
        var v:Float = ypos;// - (range.start * d);
        var p:Float = v / d;

        return (range.max - p);
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class VerticalRangeLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        if (value != null) {
            var ucy:Float = usableHeight;
            
            var m:Float = range.max - range.min;
            var d = (ucy / m);
            var startInPixels = (range.start * d) - (range.min * d);
            var endInPixels = (range.end * d) - (range.min * d);
            var cy:Float = Math.abs(endInPixels - startInPixels);

            if (cy < 0) {
                cy = 0;
            } else if (cy > ucy) {
                cy = ucy;
            }

            if (cy == 0) {
                value.height = 0;
                value.hidden = true;
            } else {
                value.height = cy;
                value.hidden = false;
            }
        }
    }

    public override function repositionChildren() {
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        
        var ucy:Float = usableHeight;
        var m:Float = range.max - range.min;
        var d = (ucy / m);

        var startInPixels = (ucy - value.height) - ((range.start * d) - (range.min * d));
        value.left = paddingLeft;
        value.top = paddingTop + startInPixels;
    }    
}

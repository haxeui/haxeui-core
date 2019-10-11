package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

@:composite(HorizontalRangeLayout)
class HorizontalRange extends Range {
    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(HorizontalRangePosFromCoord)         private override function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class HorizontalRangePosFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var range = cast(_component, Range);
        var p = cast(pos, Point);
        var xpos = p.x - range.layout.paddingLeft;
        var ucx = range.layout.usableWidth;
        if (xpos >= ucx) {
            xpos = ucx;
        }
        
        var m:Float = range.max - range.min;
        var d = (ucx / m);
        var v:Float = xpos + (range.start * d);
        var p:Float = v / d;
        
        return p;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class HorizontalRangeLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        if (value != null) {
            var ucx:Float = usableWidth;
            
            var m:Float = range.max - range.min;
            var d = (ucx / m);
            var startInPixels = (range.start * d) - (range.min * d);
            var endInPixels = (range.end * d) - (range.min * d);
            var cx:Float = Math.abs(endInPixels - startInPixels);

            if (cx < 0) {
                cx = 0;
            } else if (cx > ucx) {
                cx = ucx;
            }

            if (cx == 0) {
                value.width = 0;
                value.hidden = true;
            } else {
                value.width = Std.int(cx);
                value.hidden = false;
            }
        }
    }

    public override function repositionChildren() {
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        
        var ucx:Float = usableWidth;
        var m:Float = range.max - range.min;
        var d = (ucx / m);

        var startInPixels = (range.start * d) - (range.min * d);
        value.left = paddingLeft + startInPixels;
        value.top = paddingTop;
    }    
}

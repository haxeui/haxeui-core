package haxe.ui.components;

import haxe.ui.Toolkit;
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
@:access(haxe.ui.core.Component)
class HorizontalRangePosFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var range = cast(_component, Range);
        var p = cast(pos, Point);
        p.x -= _component.getComponentOffset().x;

        var xpos = p.x - range.layout.paddingLeft;
        var ucx = range.layout.usableWidth * Toolkit.scaleX;
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
@:access(haxe.ui.components.Range)
class HorizontalRangeLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        if (value != null) {
            var ucx:Float = usableWidth;

            var start = range.start;
            var end = range.end;
            
            if (range.virtualStart != null) {
                start = range.virtualStart;
            }
            if (range.virtualEnd != null) {
                end = range.virtualEnd;
            }
            
            var m:Float = range.max - range.min;
            var d = (ucx / m);
            var startInPixels = (start * d) - (range.min * d);
            var endInPixels = (end * d) - (range.min * d);
            var cx:Float = Math.fceil(endInPixels - startInPixels);

            if (cx < 0) {
                cx = 0;
            } else if (cx > ucx) {
                cx = ucx;
            }

            if (cx == 0) {
                value.width = 0;
                value.hidden = true;
            } else {
                value.width = cx;
                value.hidden = false;
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');

        var start = range.start;
        if (range.virtualStart != null) {
            start = range.virtualStart;
        }
        
        var ucx:Float = usableWidth;
        var m:Float = range.max - range.min;
        var d = (ucx / m);

        var startInPixels = (start * d) - (range.min * d);
        value.left = Math.ffloor(paddingLeft + startInPixels);
        value.top = paddingTop;
    }
}

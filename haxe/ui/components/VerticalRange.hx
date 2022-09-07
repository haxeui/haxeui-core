package haxe.ui.components;

import haxe.ui.Toolkit;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.components.Range.RangeBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

@:composite(VerticalRangeLayout, Builder)
class VerticalRange extends Range {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    @:call(VerticalRangePosFromCoord)         private override function posFromCoord(coord:Point):Float;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
class VerticalRangePosFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var range = cast(_component, Range);
        var p = cast(pos, Point);
        p.y -= _component.getComponentOffset().y;

        var ypos = p.y - range.layout.paddingTop;
        var ucy = range.layout.usableHeight * Toolkit.scaleY;
        if (ypos >= ucy) {
            ypos = ucy;
        }

        var min = range.min;
        if (min == null) {
            min = 0;
        }
        
        var m:Float = range.max - min;
        var d = (ucy / m);
        var v:Float = ypos; // - (range.start * d);
        var p:Float = v / d;

        return (range.max - p);
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.components.Range)
class VerticalRangeLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        if (value != null) {
            var ucy:Float = usableHeight;

            var start = range.start;
            if (start == null) {
                start = 0;
            }
            var end = range.end;
            
            if (range.virtualStart != null) {
                start = range.virtualStart;
            }
            if (range.virtualEnd != null) {
                end = range.virtualEnd;
            }
            
            var min = range.min;
            if (min == null) {
                min = 0;
            }
            
            var m:Float = range.max - min;
            var d = (ucy / m);
            var startInPixels = (start * d) - (min * d);
            var endInPixels = (end * d) - (min * d);
            var cy:Float = Math.fceil(endInPixels - startInPixels);

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
        super.repositionChildren();

        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');

        var start = range.start;
        if (start == null) {
            start = 0;
        }
        if (range.virtualStart != null) {
            start = range.virtualStart;
        }
        
        var min = range.min;
        if (min == null) {
            min = 0;
        }
        
        var ucy:Float = usableHeight;
        var m:Float = range.max - min;
        var d = (ucy / m);

        var startInPixels = (ucy - value.height) - ((start * d) - (min * d));
        value.left = paddingLeft;
        value.top = Math.ffloor(paddingTop + startInPixels);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Builder extends RangeBuilder {
    private override function showWarning() { // do nothing
    }
}
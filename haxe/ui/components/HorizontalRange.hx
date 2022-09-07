package haxe.ui.components;

import haxe.ui.Toolkit;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.components.Range.RangeBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

/**
 * A horizontal range bar.
 * 
 * **Note** - A range bar is like a prgress bar, but isnt forced to start from 0.
 */
@:composite(HorizontalRangeLayout, Builder)
class HorizontalRange extends Range {

    /**
     * Creates a new horizontal range bar.
     */
    public function new() {
        super();
    }
    
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

        var min = range.min;
        if (min == null) {
            min = 0;
        }
        
        var m:Float = range.max - min;
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
            var d = (ucx / m);
            var startInPixels = (start * d) - (min * d);
            var endInPixels = (end * d) - (min * d);
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
        
        var ucx:Float = usableWidth;
        var m:Float = range.max - min;
        var d = (ucx / m);

        var startInPixels = (start * d) - (min * d);
        value.left = Math.ffloor(paddingLeft + startInPixels);
        value.top = paddingTop;
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
package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Point;
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
        var v:Float = ypos;
        var p:Float = range.min + ((v / ucy) * m);

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
            var cy:Float = ((range.end - range.start) - range.min) / (range.max - range.min) * ucy;

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
        var y = (ucy - value.height) - (range.start - range.min) / (range.max - range.min) * ucy;

        value.left = paddingLeft;
        value.top = paddingTop + y;
    }    
}

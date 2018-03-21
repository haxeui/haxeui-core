package haxe.ui.components;

import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.util.Point;
import haxe.ui.util.Variant;

class HorizontalRange extends Range {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function registerBehaviours() {
        super.registerBehaviours();
        behaviours.register("posFromCoord", HorizontalRangePosFromCoord);
    }
    
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (width <= 0) {
            width = 150;
        }
        if (height <= 0) {
            height = 20;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HorizontalRangeLayout();
    }
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
        var v:Float = xpos;
        var p:Float = range.min + ((v / ucx) * m);

        return p;
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class HorizontalRangeLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        
        var ucx:Float = usableWidth;
        var cx:Float = ((range.end - range.start) - range.min) / (range.max - range.min) * ucx;

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

    public override function repositionChildren() {
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        
        var ucx:Float = usableWidth;
        var x = (range.start - range.min) / (range.max - range.min) * ucx;

        value.left = paddingLeft + x;
        value.top = paddingTop;
    }    
}


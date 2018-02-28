package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

class HorizontalRange extends Range {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HorizontalRangeLayout();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.HorizontalProgress2)
class HorizontalRangeLayout extends DefaultLayout {
    public function new() {
        super();
    }
    
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
        super.repositionChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('${range.cssName}-value');
        
        var ucx:Float = usableWidth;
        var x = (range.start - range.min) / (range.max - range.min) * ucx;

        value.left = paddingLeft + x;
    }    
}


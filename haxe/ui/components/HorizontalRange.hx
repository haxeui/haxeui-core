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
        _defaultLayout = new Layout();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Layout extends DefaultLayout {
    public function new() {
        super();
    }
    
    public override function resizeChildren() {
        super.resizeChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('range-value');
        if (value != null) {
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
    }

    public override function repositionChildren() {
        super.repositionChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('range-value');
        
        var x:Float = 0;
        if (value != null) {
            var ucx:Float = usableWidth;
            x = (range.start - range.min) / (range.max - range.min) * ucx;
        }
        value.left = paddingLeft + x;
    }    
}


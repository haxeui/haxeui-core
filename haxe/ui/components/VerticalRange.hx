package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

class VerticalRange extends Range {
    public function new() {
        super();
    }
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VerticalRangeLayout();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class VerticalRangeLayout extends DefaultLayout {
    public function new() {
        super();
    }
    
    public override function resizeChildren() {
        super.resizeChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('range-value');
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
        super.repositionChildren();
        
        var range:Range = cast(component, Range);
        var value:Component = findComponent('range-value');
        
        var ucy:Float = usableHeight;
        var y = (ucy - value.height) - (range.start - range.min) / (range.max - range.min) * ucy;

        value.top = paddingTop + y;
    }    
}

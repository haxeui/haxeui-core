package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

class HorizontalSlider2 extends Slider2 {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (componentWidth <= 0) {
            componentWidth = 150;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HorizontalSliderLayout();
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function createValueComponent():Range {
        return new HorizontalRange();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class HorizontalSliderLayout extends DefaultLayout {
    public override function repositionChildren() {
        super.repositionChildren();
        
        var range:Range = findComponent(Range);
        var rangeValue:Component = range.findComponent("range-value");
        
        var startThumb:Button = findComponent("start-thumb");
        var endThumb:Button = findComponent("end-thumb");
        
        if (startThumb != null) {
            startThumb.left =  (range.left + rangeValue.left) - (startThumb.width / 2);
            startThumb.top = (rangeValue.screenTop - _component.screenTop) - (startThumb.width / 2) + (rangeValue.screenTop - range.screenTop);
        }

        endThumb.left =  (range.left + rangeValue.left + rangeValue.width) - (endThumb.width / 2);
        endThumb.top = (rangeValue.screenTop - _component.screenTop) - (endThumb.width / 2) + (rangeValue.screenTop - range.screenTop);
    }
}
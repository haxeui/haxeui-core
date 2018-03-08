package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

class VerticalSlider2 extends Slider2 {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (componentHeight <= 0) {
            componentHeight = 150;
        }
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VerticalSliderLayout();
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private override function createValueComponent():Range {
        return new VerticalRange();
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class VerticalSliderLayout extends DefaultLayout {
    public override function repositionChildren() {
        super.repositionChildren();
        
        var range:Range = findComponent(Range);
        var rangeValue:Component = range.findComponent("range-value");
        
        var startThumb:Button = findComponent("start-thumb");
        var endThumb:Button = findComponent("end-thumb");

        if (startThumb != null) {
            startThumb.left =  (rangeValue.screenLeft - _component.screenLeft) - (startThumb.height / 2) + (rangeValue.screenLeft - range.screenLeft);
            startThumb.top = (range.top + rangeValue.top + rangeValue.height) - (startThumb.height / 2);
        }

        endThumb.left =  (rangeValue.screenLeft - _component.screenLeft) - (endThumb.height / 2) + (rangeValue.screenLeft - range.screenLeft);
        endThumb.top = (range.top + rangeValue.top) - (endThumb.height / 2);
    }
}
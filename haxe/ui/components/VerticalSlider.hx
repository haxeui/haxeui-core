package haxe.ui.components;

import haxe.ui.components.Slider.SliderBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

@:composite(VerticalSliderLayout, Builder)
class VerticalSlider extends Slider {
}

//***********************************************************************************************************
// Composite Layout
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
            startThumb.top = (range.top + rangeValue.top + rangeValue.height) - (startThumb.height / 2);
        }

        endThumb.top = (range.top + rangeValue.top) - (endThumb.height / 2);
    }
}


//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
private class Builder extends SliderBuilder {
    private override function createValueComponent():Range {
        return new VerticalRange();
    }
}

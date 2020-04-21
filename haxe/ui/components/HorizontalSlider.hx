package haxe.ui.components;

import haxe.ui.components.Slider.SliderBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

@:composite(HorizontalSliderLayout, Builder)
class HorizontalSlider extends Slider {
}

//***********************************************************************************************************
// Composite Layout
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
        }

        endThumb.left =  (range.left + rangeValue.left + rangeValue.width) - (endThumb.width / 2);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
private class Builder extends SliderBuilder {
    private var _slider:Slider;
    public function new(slider:Slider) {
        super(slider);
        _slider = slider;
    }
    
    private override function createValueComponent():Range {
        return new HorizontalRange();
    }
    
    public override function getStartOffset():Float {
        var start:Float = 0;
        if (_slider.start != null) {
            start = _slider.start;
        }
        return start;
    }
}

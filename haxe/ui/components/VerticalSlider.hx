package haxe.ui.components;

import haxe.ui.components.Slider.SliderBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

@:composite(VerticalSliderLayout, Builder)
class VerticalSlider extends Slider {
    public function new() {
        super();
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class VerticalSliderLayout extends DefaultLayout {
    public override function repositionChildren() {
        super.repositionChildren();

        var slider = cast(_component, Slider);
        var range:Range = findComponent(Range);
        var rangeValue:Component = range.findComponent("range-value");
        var startThumb:Button = findComponent("start-thumb");
        var endThumb:Button = findComponent("end-thumb");

        var padding:Float = 0;
        if (range != null && range.layout != null) {
            padding = range.layout.paddingTop;
        }
        
        if (startThumb != null) {
            var cy = rangeValue.height;
            if (rangeValue.hidden == true) {
                cy = 0;
            }
            startThumb.top = (range.top + rangeValue.top + cy) - (startThumb.height / 2);
            startThumb.top = Math.fceil(startThumb.top);
            if (padding > 1 && startThumb.top % 2 != 0) {
                startThumb.top += (padding / 2);
            }
        }

        var cy = rangeValue.top;
        if (rangeValue.hidden == true) {
            cy = range.height;
        }
        
        if (slider.center != null) {
            if (slider.pos >= slider.center) {
                endThumb.top = (rangeValue.top);
                endThumb.top = Math.fceil(endThumb.top);
            } else {
                endThumb.top = (rangeValue.top + rangeValue.height);
            }
        } else {
            endThumb.top = (rangeValue.top);
            endThumb.top = Math.fceil(endThumb.top);
            if (startThumb != null && endThumb.top % 2 == 0) {
                endThumb.top++;
            }
        }
        
        if (slider.minorTicks != null && range != null && range.layout != null) {
            var minorTicks = findComponents("minor-tick", Component, 1);
            if (minorTicks != null && minorTicks.length > 0) {
                var m:Float = slider.max - slider.min;
                var v:Float = slider.minorTicks;
                var n:Int = Std.int(m / v);
                
                var i = 0;
                var padding = range.layout.paddingTop + paddingTop;
                var tcy = range.layout.usableHeight / n;
                for (tick in minorTicks) {
                    tick.top = (i * tcy) + padding;
                    tick.top = Math.ffloor(tick.top);
                    i++;
                }
            }
        }
        
        if (slider.majorTicks != null && range != null && range.layout != null) {
            var majorTicks = findComponents("major-tick", Component, 1);
            if (majorTicks != null && majorTicks.length > 0) {
                var m:Float = slider.max - slider.min;
                var v:Float = slider.majorTicks;
                var n:Int = Std.int(m / v);
                
                var i = 0;
                var padding = range.layout.paddingTop + paddingTop;
                var tcy = range.layout.usableHeight / n;
                for (tick in majorTicks) {
                    tick.top = (i * tcy) + padding;
                    tick.top = Math.ffloor(tick.top);
                    i++;
                }
            }
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
private class Builder extends SliderBuilder {
    private override function createValueComponent():Range {
        return new VerticalRange();
    }
    
    private override function showWarning() { // do nothing
    }
}

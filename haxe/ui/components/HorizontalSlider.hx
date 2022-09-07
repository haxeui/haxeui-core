package haxe.ui.components;

import haxe.ui.components.Slider.SliderBuilder;
import haxe.ui.core.Component;
import haxe.ui.layouts.DefaultLayout;

/**
 * A horizontal slider component, controlled by a "stopper" that can be dragged around.
 */
@:composite(HorizontalSliderLayout, Builder)
class HorizontalSlider extends Slider {

    /**
     * Creates a new, horizontally laid slider.
     */
    public function new() {
        super();
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
class HorizontalSliderLayout extends DefaultLayout {
    public override function repositionChildren() {
        super.repositionChildren();

        var slider = cast(_component, Slider);
        var range:Range = findComponent(Range);
        var rangeValue:Component = range.findComponent("range-value");
        var startThumb:Button = findComponent("start-thumb");
        var endThumb:Button = findComponent("end-thumb");

        var padding:Float = 0;
        if (range != null && range.layout != null) {
            padding = range.layout.paddingLeft;
        }
        
        if (startThumb != null) {
            startThumb.left = (range.left + rangeValue.left) - (startThumb.width / 2);
            startThumb.left = Math.fceil(startThumb.left);
            if (padding > 1 && startThumb.left % 2 != 0) {
                startThumb.left += (padding / 2);
            }
        }

        var cx = rangeValue.width;
        if (rangeValue.hidden == true && _component.hidden == false) {
            cx = 0;
        }
        
        if (slider.center != null) {
            if (slider.pos >= slider.center) {
                endThumb.left = (range.left + rangeValue.left + cx) - (endThumb.width / 2);
            } else {
                endThumb.left = (range.left + rangeValue.left) - (endThumb.width / 2);
                if (padding > 1 && cx % 2 == 0) {
                    endThumb.left += (padding / 2);
                }
            }
        } else {
            endThumb.left = (range.left + rangeValue.left + cx) - (endThumb.width / 2);
            endThumb.left = Math.fceil(endThumb.left);
            if (startThumb != null && endThumb.left % 2 == 0) {
                endThumb.left++;
            }
        }
        
        if (slider.minorTicks != null && range != null && range.layout != null) {
            var minorTicks = findComponents("minor-tick", Component, 1);
            if (minorTicks != null && minorTicks.length > 0) {
                var m:Float = slider.max - slider.min;
                var v:Float = slider.minorTicks;
                var n:Int = Std.int(m / v);
                
                var i = 0;
                var padding = range.layout.paddingLeft + paddingLeft;
                var tcx = range.layout.usableWidth / n;
                for (tick in minorTicks) {
                    tick.left = (i * tcx) + padding;
                    tick.left = Math.fceil(tick.left);
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
                var padding = range.layout.paddingLeft + paddingLeft;
                var tcx = range.layout.usableWidth / n;
                for (tick in majorTicks) {
                    tick.left = (i * tcx) + padding;
                    tick.left = Math.fceil(tick.left);
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
    
    private override function showWarning() { // do nothing
    }
}

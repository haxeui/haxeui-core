package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.layouts.DefaultLayout;

/**
 A vertical implementation of a `Slider`
**/
@:dox(icon = "/icons/ui-slider-vertical-050.png")
class VSlider extends Slider {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VSliderLayout();
    }

    private override function createChildren() {
        super.createChildren();
        if (componentWidth <= 0) {
            componentWidth = 20;
        }
        if (componentHeight <= 0) {
            componentHeight = 150;
        }

        if (_valueBackground != null) {
        }
    }

    //***********************************************************************************************************
    // Event overrides
    //***********************************************************************************************************
    private override function _onValueBackgroundMouseDown(event:MouseEvent) {
        super._onValueBackgroundMouseDown(event);
        if (_value.hitTest(event.screenX, event.screenY) == false) {
            if (rangeEnd != rangeStart) {
                if (event.screenY < _rangeEndThumb.screenTop) {
                    _activeThumb = _rangeEndThumb;
                    var ypos:Float = event.screenY - _valueBackground.screenTop - (_activeThumb.componentHeight / 2) - _valueBackground.paddingBottom;
                    //rangeEnd = calcPosFromCoord(ypos);
                    animateRangeEnd(calcPosFromCoord(ypos));
                    _onRangeEndThumbMouseDown(event);
                } else if (event.screenY > _rangeStartThumb.screenTop + _rangeStartThumb.componentHeight) {
                    _activeThumb = _rangeStartThumb;
                    var ypos:Float = event.screenY - _valueBackground.screenTop - (_activeThumb.componentHeight / 2) - _valueBackground.paddingBottom;
                    //rangeStart = calcPosFromCoord(ypos);
                    animateRangeStart(calcPosFromCoord(ypos));
                    _onRangeStartThumbMouseDown(event);
                }
            } else {
                _activeThumb = _rangeEndThumb;
                var ypos:Float = event.screenY - _valueBackground.screenTop - (_activeThumb.componentHeight / 2) - _valueBackground.paddingBottom;
                //pos = calcPosFromCoord(ypos);
                animatePos(calcPosFromCoord(ypos), function() {
                    if (_activeThumb != null) {
                        _mouseDownOffset = (_activeThumb.componentWidth / 2) + _valueBackground.paddingBottom;
                    }
                });
                _onRangeEndThumbMouseDown(event);
            }
        }
    }

    private override function _onValueMouseDown(event:MouseEvent) {
        super._onValueMouseDown(event);
        if (rangeEnd != rangeStart) {
            _mouseDownOffset = event.screenY - _value.top;
        } else {
            _activeThumb = _rangeEndThumb;
            var ypos:Float = event.screenY - _valueBackground.screenTop - (_activeThumb.componentHeight / 2) - _valueBackground.paddingBottom;
            //pos = calcPosFromCoord(ypos);
            animatePos(calcPosFromCoord(ypos), function() {
                if (_activeThumb != null) {
                    _mouseDownOffset = (_activeThumb.componentWidth / 2) + _valueBackground.paddingBottom;
                }
            });
            _onRangeEndThumbMouseDown(event);
        }
    }

    private override function _onRangeEndThumbMouseDown(event:MouseEvent) {
        super._onRangeEndThumbMouseDown(event);
        _mouseDownOffset = event.screenY - _activeThumb.screenTop + _valueBackground.paddingBottom;
    }

    private override function _onRangeStartThumbMouseDown(event:MouseEvent) {
        super._onRangeStartThumbMouseDown(event);
        _mouseDownOffset = event.screenY - _activeThumb.screenTop + _valueBackground.paddingBottom;
    }

    private override function _onScreenMouseMove(event:MouseEvent) {
        super._onScreenMouseMove(event);
        if (_mouseDownOffset == -1) {
            return;
        }

        if (_activeThumb != null) {
            var ypos:Float = event.screenY - _valueBackground.screenTop - _mouseDownOffset;
            if (rangeEnd != rangeStart) {
                if (_activeThumb == _rangeEndThumb) {
                    rangeEnd = calcPosFromCoord(ypos);
                } else if (_activeThumb == _rangeStartThumb) {
                    rangeStart = calcPosFromCoord(ypos);
                }
            } else {
                pos = calcPosFromCoord(ypos);
            }
        } else {
            var diff = rangeEnd - rangeStart;
            var ypos:Float = event.screenY - _mouseDownOffset;
            ypos += _value.componentHeight;
            _activeThumb = _rangeStartThumb;
            var start = calcPosFromCoord(ypos - (_activeThumb.componentHeight / 2) - _valueBackground.paddingBottom);
            _activeThumb = null;

            if (start + diff > max) {
                return;
            }

            var end = start + diff;
            setRange(start, end);
        }
    }

    //***********************************************************************************************************
    // Helpers
    //***********************************************************************************************************
    private function calcPosFromCoord(ypos:Float):Float {
        var minY:Float = -(_activeThumb.componentHeight / 2);
        var maxY:Float = layout.usableHeight - (_activeThumb.componentHeight / 2) - (_valueBackground.paddingTop + _valueBackground.paddingBottom);

        if (ypos < minY) {
            ypos = minY;
        } else if (ypos > maxY) {
            ypos = maxY;
        }

        var ucy:Float = layout.usableHeight - (_valueBackground.paddingTop + _valueBackground.paddingBottom);
        var m:Float = max - min;
        var v:Float = ypos - minY;
        var newValue:Float = min + ((v / ucy) * m);
        return max - newValue;
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
class VSliderLayout extends DefaultLayout {
    public function new() {
        super();
    }

    public override function resizeChildren() {
        super.resizeChildren();

        var background:Component = component.findComponent("slider-value-background");
        var value:Component = null;
        if (background != null) {
            value = background.findComponent("slider-value");
        }
        var slider:Slider = cast component;
        if (value != null) {
            var ucy:Float = background.layout.usableHeight;

            var cy:Float = 0;
            if (slider.rangeStart == slider.rangeEnd) {
                cy = (slider.pos - slider.min) / (slider.max - slider.min) * ucy;
            } else {
                cy = ((slider.rangeEnd - slider.rangeStart) - slider.min) / (slider.max - slider.min) * ucy;
            }

            if (cy < 0) {
                cy = 0;
            } else if (cy > ucy) {
                cy = ucy;
            }

            if (cy == 0) {
                value.componentHeight = cy;
                if (value.hidden == false) {
                    value.hidden = true;
                    value.invalidateComponentStyle();
                }
            } else {
                value.componentHeight = cy;
                if (value.hidden == true) {
                    value.hidden = false;
                    value.invalidateComponentStyle();
                }
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var background:Component = component.findComponent("slider-value-background");
        var value:Component = null;
        if (background != null) {
            value = background.findComponent("slider-value");
        }
        var slider:Slider = cast component;
        if (value != null) {
            var rangeStartButton:Button = null;
            var rangeEndButton:Button = component.findComponent("slider-range-end-button");

            var ucy:Float = background.layout.usableHeight;
            var y:Float = ucy - value.componentHeight + background.layout.paddingTop;
            if (slider.rangeStart != slider.rangeEnd) {
                rangeStartButton = component.findComponent("slider-range-start-button");
                y -= (slider.rangeStart - slider.min) / (slider.max - slider.min) * ucy;
            }

            /*
            if (background.style.paddingBottom != null) {
                y += background.style.paddingBottom;
            }
            */

            value.top = y; // + background.layout.paddingBottom; // - (rangeEndButton.componentHeight / 2) + background.layout.paddingTop;

            if (rangeStartButton != null) {
                rangeStartButton.top = y + paddingTop + value.componentHeight - (rangeStartButton.componentHeight / 2);
            }
            if (rangeEndButton != null) {
                rangeEndButton.top = paddingTop + value.top - (rangeEndButton.componentHeight / 2);
            }
        }
    }
}

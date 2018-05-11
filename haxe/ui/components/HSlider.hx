package haxe.ui.components;

import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.layouts.DefaultLayout;

/**
 A horizontal implementation of a `Slider`
**/
@:dox(icon = "/icons/ui-slider-050.png")
class HSlider extends Slider {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HSliderLayout();
    }

    private override function createChildren() {
        super.createChildren();

        if (componentWidth <= 0) {
            componentWidth = 150;
        }
        if (componentHeight <= 0) {
            componentHeight = 20;
        }

        if (_valueBackground != null) {
            /*
            componentWidth = 150;
            componentHeight = 20;
            */
            //layout = new HSliderLayout();
            //_valueBackground.layout.allowLeftChange = false;
        }
    }

    //***********************************************************************************************************
    // Event overrides
    //***********************************************************************************************************
    private override function _onValueBackgroundMouseDown(event:MouseEvent) {
        super._onValueBackgroundMouseDown(event);
        if (_value.hitTest(event.screenX, event.screenY) == false) {
            if (rangeEnd != rangeStart) {
                if (event.screenX < _rangeStartThumb.screenLeft) {
                    _activeThumb = _rangeStartThumb;
                    var xpos:Float = event.screenX - _valueBackground.screenLeft - (_activeThumb.componentWidth / 2) - _valueBackground.paddingLeft;
                    animateRangeStart(calcPosFromCoord(xpos));
                    //rangeStart = calcPosFromCoord(xpos);
                    _onRangeStartThumbMouseDown(event);
                } else if (event.screenX > _rangeEndThumb.screenLeft + _rangeEndThumb.componentWidth) {
                    _activeThumb = _rangeEndThumb;
                    var xpos:Float = event.screenX - _valueBackground.screenLeft - (_activeThumb.componentWidth / 2) - _valueBackground.paddingLeft;
                    animateRangeEnd(calcPosFromCoord(xpos));
                    //rangeEnd = calcPosFromCoord(xpos);
                    _onRangeEndThumbMouseDown(event);
                }
            } else {
                _activeThumb = _rangeEndThumb;
                var xpos:Float = event.screenX - _valueBackground.screenLeft - (_activeThumb.componentWidth / 2) - _valueBackground.paddingLeft;
                animatePos(calcPosFromCoord(xpos), function() {
                    if (_activeThumb != null) {
                        _mouseDownOffset = (_activeThumb.componentWidth / 2) + _valueBackground.paddingLeft;
                    }
                });
                //pos = calcPosFromCoord(xpos);
                _onRangeEndThumbMouseDown(event);
            }
        }
    }

    private override function _onValueMouseDown(event:MouseEvent) {
        super._onValueMouseDown(event);
        if (rangeEnd != rangeStart) {
            _mouseDownOffset = event.screenX - _value.left;
        } else {
            _activeThumb = _rangeEndThumb;
            var xpos:Float = event.screenX - _valueBackground.screenLeft - (_activeThumb.componentWidth / 2) - _valueBackground.paddingLeft;
            animatePos(calcPosFromCoord(xpos), function() {
                if (_activeThumb != null) {
                    _mouseDownOffset = (_activeThumb.componentWidth / 2) + _valueBackground.paddingLeft;
                }
            });
            //pos = calcPosFromCoord(xpos);
            _onRangeEndThumbMouseDown(event);
        }
    }

    private override function _onRangeEndThumbMouseDown(event:MouseEvent) {
        super._onRangeEndThumbMouseDown(event);
        _mouseDownOffset = event.screenX - _activeThumb.screenLeft + _valueBackground.paddingLeft;
    }

    private override function _onRangeStartThumbMouseDown(event:MouseEvent) {
        super._onRangeStartThumbMouseDown(event);
        _mouseDownOffset = event.screenX - _activeThumb.screenLeft + _valueBackground.paddingLeft;
    }

    private override function _onScreenMouseMove(event:MouseEvent) {
        super._onScreenMouseMove(event);
        if (_mouseDownOffset == -1) {
            return;
        }

        if (_activeThumb != null) {
            var xpos:Float = event.screenX - _valueBackground.screenLeft - _mouseDownOffset;
            if (rangeEnd != rangeStart) {
                if (_activeThumb == _rangeEndThumb) {
                    rangeEnd = calcPosFromCoord(xpos);
                } else if (_activeThumb == _rangeStartThumb) {
                    rangeStart = calcPosFromCoord(xpos);
                }
            } else {
                pos = calcPosFromCoord(xpos);
            }
        } else {
            var diff = rangeEnd - rangeStart;
            var xpos:Float = event.screenX - _mouseDownOffset;
            _activeThumb = _rangeStartThumb;
            var start = calcPosFromCoord(xpos - (_activeThumb.componentWidth / 2) - _valueBackground.paddingLeft);
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
    private function calcPosFromCoord(xpos:Float):Float {
        var minX:Float = -(_activeThumb.componentWidth / 2);
        var maxX:Float = layout.usableWidth - (_activeThumb.componentWidth / 2) - (_valueBackground.paddingLeft + _valueBackground.paddingRight);

        if (xpos < minX) {
            xpos = minX;
        } else if (xpos > maxX) {
            xpos = maxX;
        }

        var ucx:Float = layout.usableWidth - (_valueBackground.paddingLeft + _valueBackground.paddingRight);
        //var ucx:Float = layout.innerWidth - (_valueBackground.paddingLeft + _valueBackground.paddingRight);
        var m:Float = max - min;
        var v:Float = xpos - minX;
        var newValue:Float = min + ((v / ucx) * m);
        return newValue;
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
class HSliderLayout extends DefaultLayout {
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
            var ucx:Float = background.layout.usableWidth;

            var cx:Float = 0;
            if (slider.rangeStart == slider.rangeEnd) {
                cx = (slider.pos - slider.min) / (slider.max - slider.min) * ucx;
            } else {
                cx = ((slider.rangeEnd - slider.rangeStart) - slider.min) / (slider.max - slider.min) * ucx;
            }

            if (cx < 0) {
                cx = 0;
            } else if (cx > ucx) {
                cx = ucx;
            }

            if (cx == 0) {
                value.componentWidth = cx;
                if (value.hidden == false) {
                    value.hidden = true;
                    value.invalidateComponentStyle();
                }
            } else {
                value.componentWidth = cx;
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

            var x:Float = 0;
            if (slider.rangeStart != slider.rangeEnd) {
                rangeStartButton = component.findComponent("slider-range-start-button");
                var ucx:Float = background.layout.usableWidth;
                x = (slider.rangeStart - slider.min) / (slider.max - slider.min) * ucx;
            }

            //x += background.layout.paddingLeft;
            value.left = x + background.layout.paddingLeft;

            if (rangeStartButton != null) {
                rangeStartButton.left = x; // - (rangeStartButton.width / 2);
            }
            if (rangeEndButton != null) {
                rangeEndButton.left = paddingLeft + value.left + value.componentWidth - (rangeEndButton.componentWidth / 2);
            }
        }
    }
}
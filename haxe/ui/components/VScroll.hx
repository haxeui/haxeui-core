package haxe.ui.components;

import haxe.ui.core.MouseEvent;
import haxe.ui.layouts.DefaultLayout;

/**
 A vertical implementation of a `Scroll`
**/
@:dox(icon = "/icons/ui-scroll-bar.png")
class VScroll extends Scroll {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************

    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new VScrollLayout();
    }

    //***********************************************************************************************************
    // Event overrides
    //***********************************************************************************************************
    private override function _onThumbMouseDown(event:MouseEvent) {
        super._onThumbMouseDown(event);

        _mouseDownOffset = event.screenY - _thumb.top + layout.paddingTop;
    }

    private override function _onScreenMouseMove(event:MouseEvent) {
        super._onScreenMouseMove(event);
        if (_mouseDownOffset == -1) {
            return;
        }

        var ypos:Float = event.screenY - _mouseDownOffset;
        var minY:Float = 0;
        if (_deincButton != null && _deincButton.hidden == false) {
            minY = _deincButton.componentHeight + layout.verticalSpacing;
        }

        var maxY:Float = layout.usableHeight - _thumb.componentHeight;
        if (_deincButton != null && _deincButton.hidden == false) {
            maxY += _deincButton.componentHeight + layout.verticalSpacing;
        }

        if (ypos < minY) {
            ypos = minY;
        } else if (ypos > maxY) {
            ypos = maxY;
        }

        var ucy:Float = layout.usableHeight;
        ucy -= _thumb.componentHeight;
        var m:Int = Std.int(max - min);
        var v:Float = ypos - minY;
        var newValue:Float = min + ((v / ucy) * m);
        pos = newValue;
    }

    private override function _onMouseDown(event:MouseEvent) {
        if (event.screenY < _thumb.screenTop) {
            animatePos(pos - pageSize);
        } else if (event.screenY > _thumb.screenTop + _thumb.componentHeight) {
            animatePos(pos + pageSize);
        }
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
class VScrollLayout extends DefaultLayout {
    public function new() {
        super();
    }

    public override function resizeChildren() {
        super.resizeChildren();

        var scroll:Scroll = cast component;
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var ucy:Float = usableHeight;
            var thumbHeight = (scroll.pageSize / m) * ucy;
            if (thumbHeight < innerWidth) {
                thumbHeight = innerWidth;
            } else if (thumbHeight > ucy) {
                thumbHeight = ucy;
            }
            if (thumbHeight > 0 && Math.isNaN(thumbHeight) == false) {
                thumb.componentHeight = thumbHeight;
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (inc != null && hidden(inc) == false) {
            inc.top = component.componentHeight - inc.componentHeight - paddingBottom;
        }

        var scroll:Scroll = cast component;
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var u:Float = usableHeight;
            u -= thumb.componentHeight;
            var y:Float = ((scroll.pos - scroll.min) / m) * u;
            y += paddingTop;
            if (deinc != null && hidden(deinc) == false) {
                y += deinc.componentHeight + verticalSpacing;
            }
            thumb.top = y;
        }
    }

    // usable height returns the amount of available space for % size components
    private override function get_usableHeight():Float {
        var ucy:Float = innerHeight;
        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (deinc != null && hidden(deinc) == false) {
            ucy -= deinc.componentHeight + verticalSpacing;
        }
        if (inc != null && hidden(inc) == false) {
            ucy -= inc.componentHeight + verticalSpacing;
        }
        return ucy;
    }
}
package haxe.ui.components;

import haxe.ui.core.MouseEvent;
import haxe.ui.layouts.DefaultLayout;

/**
 A horizontal implementation of a `Scroll`
**/
@:dox(icon = "/icons/ui-scroll-bar-horizontal.png")
class HScroll extends Scroll {
    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new HScrollLayout();
    }

    //***********************************************************************************************************
    // Event overrides
    //***********************************************************************************************************
    private override function _onThumbMouseDown(event:MouseEvent) {
        super._onThumbMouseDown(event);

        _mouseDownOffset = event.screenX - _thumb.left + layout.paddingLeft;
    }

    private override function _onScreenMouseMove(event:MouseEvent) {
        super._onScreenMouseMove(event);
        if (_mouseDownOffset == -1) {
            return;
        }

        var xpos:Float = event.screenX - _mouseDownOffset;
        var minX:Float = 0;
        if (_deincButton != null && _deincButton.hidden == false) {
            minX = _deincButton.componentWidth + layout.horizontalSpacing;
        }
        var maxX:Float = layout.usableWidth - _thumb.componentWidth;
        if (_deincButton != null && _deincButton.hidden == false) {
            maxX += _deincButton.componentWidth + layout.horizontalSpacing;
        }
        if (xpos < minX) {
            xpos = minX;
        } else if (xpos > maxX) {
            xpos = maxX;
        }

        var ucx:Float = layout.usableWidth;
        ucx -= _thumb.componentWidth;
        var m:Int = Std.int(max - min);
        var v:Float = xpos - minX;
        var newValue:Float = min + ((v / ucx) * m);
        pos = newValue;
    }

    private override function _onMouseDown(event:MouseEvent) {
        if (event.screenX < _thumb.screenLeft) {
            animatePos(pos - pageSize);
        } else if (event.screenX > _thumb.screenLeft + _thumb.componentWidth) {
            animatePos(pos + pageSize);
        }
    }
}

//***********************************************************************************************************
// Custom layouts
//***********************************************************************************************************
@:dox(hide)
class HScrollLayout extends DefaultLayout {
    public function new() {
        super();
    }

    public override function resizeChildren() {
        super.resizeChildren();

        var scroll:Scroll = cast component;
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var ucx:Float = usableWidth;
            var thumbWidth = (scroll.pageSize / m) * ucx;
            if (thumbWidth < innerHeight) {
                thumbWidth = innerHeight;
            } else if (thumbWidth > ucx) {
                thumbWidth = ucx;
            }
            if (thumbWidth > 0 && Math.isNaN(thumbWidth) == false) {
                thumb.componentWidth = thumbWidth;
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (inc != null && hidden(inc) == false) {
            inc.left = component.componentWidth - inc.componentWidth - paddingRight;
        }

        var scroll:Scroll = cast component;
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var u:Float = usableWidth;
            u -= thumb.componentWidth;
            var x:Float = ((scroll.pos - scroll.min) / m) * u;
            x += paddingLeft;
            if (deinc != null && hidden(deinc) == false) {
                x += deinc.componentWidth + horizontalSpacing;
            }
            thumb.left = x;
        }
    }

    // usable height returns the amount of available space for % size components
    private override function get_usableWidth():Float {
        var ucx:Float = innerWidth;
        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (deinc != null && hidden(deinc) == false) {
            ucx -= deinc.componentWidth + horizontalSpacing;
        }
        if (inc != null && hidden(inc) == false) {
            ucx -= inc.componentWidth + horizontalSpacing;
        }
        return ucx;
    }
}
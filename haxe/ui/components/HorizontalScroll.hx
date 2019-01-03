package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

class HorizontalScroll extends Scroll {
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function registerBehaviours() {
        super.registerBehaviours();
        behaviours.register("posFromCoord", PosFromCoord);
        behaviours.register("applyPageFromCoord", ApplyPageFromCoord);
    }
    
    private override function createChildren() { // TODO: this should be min-width / min-height in theme css when the new css engine is done
        super.createChildren();
        if (componentWidth <= 0) {
            componentWidth = 150;
        }
    }
    
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayoutClass = HorizontalScrollLayout;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class PosFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var p = cast(pos, Point);
        var scroll:Scroll = cast(_component, Scroll);
        var deinc:Button = _component.findComponent("scroll-deinc-button");
        var thumb:Button = _component.findComponent("scroll-thumb-button");
        
        var xpos:Float = p.x;
        var minX:Float = 0;
        if (deinc != null && deinc.hidden == false) {
            minX = deinc.width + scroll.layout.horizontalSpacing;
        }
        var maxX:Float = scroll.layout.usableWidth - thumb.width;
        if (deinc != null && deinc.hidden == false) {
            maxX += deinc.width + scroll.layout.horizontalSpacing;
        }
        if (xpos < minX) {
            xpos = minX;
        } else if (xpos > maxX) {
            xpos = maxX;
        }

        var ucx:Float = scroll.layout.usableWidth;
        ucx -= thumb.width;
        var m:Int = Std.int(scroll.max - scroll.min);
        var v:Float = xpos - minX;
        var value:Float = scroll.min + ((v / ucx) * m);
        
        return value;
    }
}

@:dox(hide) @:noCompletion
private class ApplyPageFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var p = cast(pos, Point);
        var scroll:Scroll = cast(_component, Scroll);
        var thumb:Button = _component.findComponent("scroll-thumb-button");
        
        if (p.x < thumb.screenLeft) {
            scroll.pos -= scroll.pageSize;
        } else if (p.x > thumb.screenLeft + thumb.width) {
            scroll.pos += scroll.pageSize;
        }
        
        return null;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
private class HorizontalScrollLayout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var scroll:Scroll = cast(component, Scroll);
        var thumb:Button = component.findComponent("scroll-thumb-button");
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
                thumb.width = thumbWidth;
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (inc != null && hidden(inc) == false) {
            inc.left = component.width - inc.width - paddingRight;
        }

        var scroll:Scroll = cast(component, Scroll);
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var u:Float = usableWidth;
            u -= thumb.componentWidth;
            var x:Float = ((scroll.pos - scroll.min) / m) * u;
            x += paddingLeft;
            if (deinc != null && hidden(deinc) == false) {
                x += deinc.width + horizontalSpacing;
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
            ucx -= deinc.width + horizontalSpacing;
        }
        if (inc != null && hidden(inc) == false) {
            ucx -= inc.width + horizontalSpacing;
        }
        return ucx;
    }
}
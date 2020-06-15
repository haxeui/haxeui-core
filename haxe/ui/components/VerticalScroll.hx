package haxe.ui.components;

import haxe.ui.behaviours.Behaviour;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.geom.Point;
import haxe.ui.util.Variant;

class VerticalScroll extends Scroll {
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
        if (componentHeight <= 0) {
            componentHeight = 150;
        }
    }
    
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayoutClass = VerticalScrollLayout;
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
        
        var ypos:Float = p.y;
        var minY:Float = 0;
        if (deinc != null && deinc.hidden == false) {
            minY = deinc.height + scroll.layout.verticalSpacing;
        }

        var maxY:Float = scroll.layout.usableHeight - thumb.height;
        if (deinc != null && deinc.hidden == false) {
            maxY += deinc.height + scroll.layout.verticalSpacing;
        }

        if (ypos < minY) {
            ypos = minY;
        } else if (ypos > maxY) {
            ypos = maxY;
        }

        var ucy:Float = scroll.layout.usableHeight;
        ucy -= thumb.height;
        var m:Int = Std.int(scroll.max - scroll.min);
        var v:Float = ypos - minY;
        var value:Float = scroll.min + ((v / ucy) * m);
        
        return value;
    }
}

@:dox(hide) @:noCompletion
private class ApplyPageFromCoord extends Behaviour {
    public override function call(pos:Any = null):Variant {
        var p = cast(pos, Point);
        var scroll:Scroll = cast(_component, Scroll);
        var thumb:Button = _component.findComponent("scroll-thumb-button");
        
        if (p.y < thumb.screenTop) {
            scroll.pos -= scroll.pageSize;
        } else if (p.y > thumb.screenTop + thumb.height) {
            scroll.pos += scroll.pageSize;
        }
        
        return null;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class VerticalScrollLayout extends DefaultLayout {
    public function new() {
        super();
    }

    public override function resizeChildren() {
        super.resizeChildren();

        var scroll:Scroll = cast(component, Scroll);
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
                thumb.height = thumbHeight;
            }
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();

        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (inc != null && hidden(inc) == false) {
            inc.top = component.height - inc.height - paddingBottom;
        }

        var scroll:Scroll = cast(component, Scroll);
        var thumb:Button =  component.findComponent("scroll-thumb-button");
        if (thumb != null) {
            var m:Float = scroll.max - scroll.min;
            var u:Float = usableHeight;
            u -= thumb.height;
            var y:Float = ((scroll.pos - scroll.min) / m) * u;
            y += paddingTop;
            if (deinc != null && hidden(deinc) == false) {
                y += deinc.height + verticalSpacing;
            }
            thumb.left = Math.fround(thumb.left);
            thumb.top = y;
        }
    }

    // usable height returns the amount of available space for % size components
    private override function get_usableHeight():Float {
        var ucy:Float = innerHeight;
        var deinc:Button = component.findComponent("scroll-deinc-button");
        var inc:Button = component.findComponent("scroll-inc-button");
        if (deinc != null && hidden(deinc) == false) {
            ucy -= deinc.height + verticalSpacing;
        }
        if (inc != null && hidden(inc) == false) {
            ucy -= inc.height + verticalSpacing;
        }
        return ucy;
    }
}
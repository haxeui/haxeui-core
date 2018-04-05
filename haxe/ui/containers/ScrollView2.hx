package haxe.ui.containers;

import haxe.ui.components.HorizontalScroll2;
import haxe.ui.components.VerticalScroll2;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.Platform;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.validation.InvalidationFlags;

class ScrollView2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new ScrollViewLayout();
    }
    
    private override function registerComposite() {
       super.registerComposite();
       _compositeBuilderClass = Builder;
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateInternal() {
        var scrollInvalid = isInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT);

        super.validateInternal();

        if (scrollInvalid || layoutInvalid) {
            cast(_compositeBuilder, Builder).checkScrolls(); // TODO: would be nice to not have this
            cast(_compositeBuilder, Builder).updateScrollRect(); // TODO: or this
        }
    }
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    public override function addComponent(child:Component):Component { // TODO: would be nice to move this
        var v = null;
        if (Std.is(child, HorizontalScroll2) || Std.is(child, VerticalScroll2) || child.hasClass("scrollview-contents")) {
            v = super.addComponent(child);
        } else {
            cast(_compositeBuilder, Builder).createContentContainer(); // TODO: would be nice to not have this
            v = cast(_compositeBuilder, Builder)._contents.addComponent(child); // TODO: or this
        }
        return v;
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************

//***********************************************************************************************************
// Events
//***********************************************************************************************************

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.containers.ScrollView2)
private class Builder extends CompositeBuilder {
    private var _contents:Box;
    
    public override function create() {
        trace("create");
        createContentContainer();
    }
    
    public override function destroy() {
    }
    
    private function createContentContainer() {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.id = "temp";
            //_contents.registerEvent(UIEvent.RESIZE, _onContentsResized);
            _contents.layout = LayoutFactory.createFromName("vertical"); // TODO: temp
            _component.addComponent(_contents);
        }
    }
    
    private function checkScrolls() {
        var usableSize:Size = _component.layout.usableSize;
        
        var horizontalConstraint = _contents;
        var verticalConstraint = _contents;
        
        var hscroll:HorizontalScroll2 = _component.findComponent(HorizontalScroll2, false);
        var hscrollOffset = 0;
        
        if (horizontalConstraint.width > usableSize.width) {
            if (hscroll == null) {
                hscroll = new HorizontalScroll2();
                hscroll.percentWidth = 100;
                hscroll.id = "scrollview-hscroll";
                //hscroll.registerEvent(UIEvent.CHANGE, _onHScroll);
                _component.addComponent(hscroll);
            }

            hscroll.hidden = false;
            hscroll.max = horizontalConstraint.width - usableSize.width - hscrollOffset; // _contents.layout.horizontalSpacing;
            hscroll.pageSize = (usableSize.width / horizontalConstraint.width) * hscroll.max;

            hscroll.syncValidation();    //avoid another pass
        } else {
            if (hscroll != null) {
                hscroll.hidden = true;
            }
        }

        var vscroll:VerticalScroll2 = _component.findComponent(VerticalScroll2, false);
        
        if (verticalConstraint.height > usableSize.height) {
            if (vscroll == null) {
                vscroll = new VerticalScroll2();
                vscroll.percentHeight = 100;
                vscroll.id = "scrollview-vscroll";
                vscroll.registerEvent(UIEvent.CHANGE, function(e) {
                    trace("vscroll");
                    _component.invalidate(InvalidationFlags.SCROLL);
                });
                _component.addComponent(vscroll);
            }

            vscroll.hidden = false;
            vscroll.max = verticalConstraint.height - usableSize.height;
            vscroll.pageSize = (usableSize.height / verticalConstraint.height) * vscroll.max;

            vscroll.syncValidation();    //avoid another pass
        } else {
            if (vscroll != null) {
                vscroll.hidden = true;
            }
        }
    }
    
    private function updateScrollRect() {
        if (_contents == null) {
            return;
        }

        var usableSize = _component.layout.usableSize;

        var clipCX = usableSize.width;
        if (clipCX > _contents.width) {
            clipCX = _contents.width;
        }
        var clipCY = usableSize.height;
        if (clipCY > _contents.height) {
            clipCY = _contents.height;
        }

        var hscroll = _component.findComponent(HorizontalScroll2, false);
        var vscroll = _component.findComponent(VerticalScroll2, false);
        
        var xpos:Float = 0;
        if (hscroll != null) {
            xpos = hscroll.pos;
        }
        var ypos:Float = 0;
        if (vscroll != null) {
            ypos = vscroll.pos;
        }
        

        var rc:Rectangle = new Rectangle(Std.int(xpos), Std.int(ypos), clipCX, clipCY);
        _contents.componentClipRect = rc;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ScrollViewLayout extends DefaultLayout {
    private override function repositionChildren() {
        var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
        if (contents == null) {
            return;
        }

        var hscroll = component.findComponent(HorizontalScroll2, false);
        var vscroll = component.findComponent(VerticalScroll2, false);

        var ucx = innerWidth;
        var ucy = innerHeight;

        if (hscroll != null && hidden(hscroll) == false) {
            var ucy = innerHeight;
            hscroll.moveComponent(paddingLeft, ucy - hscroll.componentHeight + paddingBottom);
        }

        if (vscroll != null && hidden(vscroll) == false) {
            var ucx = innerWidth;
            vscroll.moveComponent(ucx - vscroll.componentWidth + paddingRight, paddingTop);
        }

        var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
        if (contents != null) {
            contents.moveComponent(paddingLeft, paddingTop);
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll = component.findComponent(HorizontalScroll2, false);
        var vscroll = component.findComponent(VerticalScroll2, false);
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        if (cast(component, ScrollView2).native == true) {
            var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
            if (contents != null) {
                if (contents.componentWidth > size.width) {
                    size.height -= Platform.hscrollHeight;
                }
                if (contents.componentHeight > size.height) {
                    size.width -= Platform.vscrollWidth;
                }
            }
        }

        return size;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var hscroll = component.findComponent(HorizontalScroll2, false);
        var vscroll = component.findComponent(VerticalScroll2, false);
        var size:Size = super.calcAutoSize([hscroll, vscroll]);
        if (hscroll != null && hscroll.hidden == false) {
            size.height += hscroll.componentHeight;
        }
        if (vscroll != null && vscroll.hidden == false) {
            size.width += vscroll.componentWidth;
        }
        
        if (cast(component, ScrollView2).native == true) {
            var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
            if (contents != null) {
                if (contents.width > component.width) {
                    size.height += Platform.hscrollHeight;
                }
                if (contents.height > component.height) {
                    size.width += Platform.vscrollWidth;
                }
            }
        }
        
        return size;
    }
}

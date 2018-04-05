package haxe.ui.containers;

import haxe.ui.components.HorizontalScroll2;
import haxe.ui.components.VerticalScroll2;
import haxe.ui.core.Component;
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
    private override function createChildren() {
        super.createChildren();
        createContentContainer();
    }
    
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayout = new ScrollViewLayout();
    }
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private inline function invalidateScroll() {
        invalidate(InvalidationFlags.SCROLL);
    }

    private override function validateInternal() {
        var scrollInvalid = isInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT);

        super.validateInternal();

        if (scrollInvalid || layoutInvalid) {
            validateScroll();
        }
    }

    private function validateScroll() {
        /*
        if(behaviourGet("hscrollPos") != _hscrollPos)
        {
            behaviourSet("hscrollPos", _hscrollPos);
            handleBindings(["hscrollPos"]);
        }

        if(behaviourGet("vscrollPos") != _vscrollPos)
        {
            behaviourSet("vscrollPos", _vscrollPos);
            handleBindings(["vscrollPos"]);
        }
        */

        checkScrolls();
        updateScrollRect();
    }
    
    private function checkScrolls() {
        var usableSize:Size = layout.usableSize;
        
        var horizontalConstraint = _contents;
        var verticalConstraint = _contents;
        
        var hscroll:HorizontalScroll2 = findComponent(HorizontalScroll2, false);
        var hscrollOffset = 0;
        
        if (horizontalConstraint.componentWidth > usableSize.width) {
            if (hscroll == null) {
                hscroll = new HorizontalScroll2();
                hscroll.percentWidth = 100;
                hscroll.id = "scrollview-hscroll";
                //hscroll.registerEvent(UIEvent.CHANGE, _onHScroll);
                addComponent(hscroll);
            }

            hscroll.hidden = false;
            hscroll.max = horizontalConstraint.componentWidth - usableSize.width - hscrollOffset; // _contents.layout.horizontalSpacing;
            hscroll.pageSize = (usableSize.width / horizontalConstraint.componentWidth) * hscroll.max;

            hscroll.syncValidation();    //avoid another pass
        } else {
            if (hscroll != null) {
                hscroll.hidden = true;
            }
        }

        var vscroll:VerticalScroll2 = findComponent(VerticalScroll2, false);
        
        if (verticalConstraint.componentHeight > usableSize.height) {
            if (vscroll == null) {
                vscroll = new VerticalScroll2();
                vscroll.percentHeight = 100;
                vscroll.id = "scrollview-vscroll";
                vscroll.registerEvent(UIEvent.CHANGE, function(e) {
                    trace("vscroll");
                    invalidateScroll();
                });
                addComponent(vscroll);
            }

            vscroll.hidden = false;
            vscroll.max = verticalConstraint.componentHeight - usableSize.height;
            vscroll.pageSize = (usableSize.height / verticalConstraint.componentHeight) * vscroll.max;

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

        var usableSize = layout.usableSize;

        var clipCX = usableSize.width;
        if (clipCX > _contents.width) {
            clipCX = _contents.width;
        }
        var clipCY = usableSize.height;
        if (clipCY > _contents.height) {
            clipCY = _contents.height;
        }

        var hscroll = findComponent(HorizontalScroll2, false);
        var vscroll = findComponent(VerticalScroll2, false);
        
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
    
    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************
    private var _contents:Box;
    private function createContentContainer() {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.id = "temp";
            //_contents.registerEvent(UIEvent.RESIZE, _onContentsResized);
            _contents.layout = LayoutFactory.createFromName("vertical"); // TODO: temp
            addComponent(_contents);
        }
    }
    
    public override function addComponent(child:Component):Component { // TODO: would be nice to move this
        var v = null;
        if (Std.is(child, HorizontalScroll2) || Std.is(child, VerticalScroll2) || child.hasClass("scrollview-contents")) {
            v = super.addComponent(child);
        } else {
            createContentContainer();
            v = _contents.addComponent(child);
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
// Composite Layout
//***********************************************************************************************************
@:dox(hide)
private class ScrollViewLayout extends DefaultLayout {
    public function new() {
        super();
    }

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

package haxe.ui.containers;

import haxe.ui.components.HorizontalScroll2;
import haxe.ui.components.VScroll;
import haxe.ui.components.VerticalScroll2;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.Platform;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.validation.InvalidationFlags;

@:composite(ScrollViewLayout, Events, Builder) // TODO: this would be nice to implement to remove alot of boilerplate
class ScrollView2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(DefaultBehaviour)   public var virtual:Bool;
    @:behaviour(VScrollPos)   public var vscrollPos:Float;
    @:behaviour(VScrollMax)   public var vscrollMax:Float;
    @:behaviour(VScrollPageSize)   public var vscrollPageSize:Float;
    
    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() { // TODO: remove this eventually, @:layout(...) or something
        super.createDefaults();
        _defaultLayout = new ScrollViewLayout();
    }
    
    private override function registerComposite() { // TODO: remove this eventually, @:composite(...) or something
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
@:access(haxe.ui.core.Component)
private class VScrollPos extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        var vscroll = _scrollview.findComponent(VerticalScroll2, false);
        if (_scrollview.virtual == true) {
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, Builder).createVScroll();
            }
            vscroll.pos = _value;
            
        } else if (vscroll != null) {
            vscroll.pos = _value;
        }
    }
}

@:access(haxe.ui.core.Component)
private class VScrollMax extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll2, false);
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, Builder).createVScroll();
            }
            vscroll.max = _value;
        }
    }
}

@:access(haxe.ui.core.Component)
private class VScrollPageSize extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll2, false);
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, Builder).createVScroll();
            }
            vscroll.pageSize = _value;
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
private class Events extends haxe.ui.core.Events {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function register() {
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        
        if (vscroll != null && vscroll.hasEvent(UIEvent.CHANGE, onVScroll) == false) {
            vscroll.registerEvent(UIEvent.CHANGE, onVScroll);
        }
    }
    
    public override function unregister() {
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        
        if (vscroll != null && vscroll.hasEvent(UIEvent.CHANGE, onVScroll) == true) {
            vscroll.unregisterEvent(UIEvent.CHANGE, onVScroll);
        }
    }
    
    private function onVScroll(event:UIEvent) {
        _scrollview.invalidate(InvalidationFlags.SCROLL);
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.containers.ScrollView2)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _scrollview:ScrollView2;
    private var _contents:Box;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function create() {
        createContentContainer();
        _component.registerInternalEvents(Events);
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
        if (_scrollview.virtual == true) {
            return;
        }
        
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
                vscroll = createVScroll();
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
    
    public function createVScroll():VerticalScroll2 {
        var vscroll = new VerticalScroll2();
        vscroll.percentHeight = 100;
        vscroll.id = "scrollview-vscroll";
        _component.addComponent(vscroll);
        _component.registerInternalEvents(true);
        return vscroll;
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

        var xpos:Float = 0;
        var ypos:Float = 0;

        if (_scrollview.virtual == false) {
            var hscroll = _component.findComponent(HorizontalScroll2, false);
            if (hscroll != null) {
                xpos = hscroll.pos;
            }
            
            var vscroll = _component.findComponent(VerticalScroll2, false);
            if (vscroll != null) {
                ypos = vscroll.pos;
            }
        }
        
        var rc:Rectangle = new Rectangle(xpos, ypos, clipCX, clipCY);
        _contents.componentClipRect = rc;
    }
}

//***********************************************************************************************************
// Composite Layout
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class ScrollViewLayout extends DefaultLayout {
    private override function repositionChildren() {
        var contents:Component = component.findComponent("scrollview-contents", false, "css");
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

        var contents:Component = component.findComponent("scrollview-contents", false, "css");
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
            var contents:Component = component.findComponent("scrollview-contents", false, "css");
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
            var contents:Component = component.findComponent("scrollview-contents", false, "css");
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

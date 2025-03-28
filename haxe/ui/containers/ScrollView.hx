package haxe.ui.containers;

import haxe.ui.actions.ActionType;
import haxe.ui.behaviours.Behaviour;
import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.HorizontalScroll;
import haxe.ui.components.Label;
import haxe.ui.components.Scroll;
import haxe.ui.components.VerticalScroll;
import haxe.ui.constants.MouseButton;
import haxe.ui.constants.Priority;
import haxe.ui.constants.ScrollMode;
import haxe.ui.constants.ScrollPolicy;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IScroller;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.ScrollEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Size;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.ScrollViewLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;

@:composite(ScrollViewEvents, ScrollViewBuilder, ScrollViewLayout)
class ScrollView extends InteractiveComponent implements IScroller {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(Virtual)                                 public var virtual:Bool;
    @:clonable @:behaviour(ContentLayoutName, "vertical")           public var contentLayoutName:String;
    @:clonable @:behaviour(ContentWidth)                            public var contentWidth:Null<Float>;
    @:clonable @:behaviour(PercentContentWidth)                     public var percentContentWidth:Null<Float>;
    @:clonable @:behaviour(ContentHeight)                           public var contentHeight:Null<Float>;
    @:clonable @:behaviour(PercentContentHeight)                    public var percentContentHeight:Null<Float>;
    @:clonable @:behaviour(HScrollPos)                              public var hscrollPos:Float;
    @:clonable @:behaviour(HScrollMax)                              public var hscrollMax:Float;
    @:clonable @:behaviour(HScrollPageSize)                         public var hscrollPageSize:Float;
    @:clonable @:behaviour(HScrollThumbSize)                        public var hscrollThumbSize:Null<Float>;
    @:clonable @:behaviour(VScrollPos)                              public var vscrollPos:Float;
    @:clonable @:behaviour(VScrollMax)                              public var vscrollMax:Float;
    @:clonable @:behaviour(VScrollPageSize)                         public var vscrollPageSize:Float;
    @:clonable @:behaviour(VScrollThumbSize)                        public var vscrollThumbSize:Null<Float>;
    @:clonable @:behaviour(ThumbSize)                               public var thumbSize:Null<Float>;
    @:clonable @:behaviour(DefaultBehaviour, MouseButton.LEFT)      public var scrollMouseButton:MouseButton;
    @:clonable @:behaviour(ScrollModeBehaviour, ScrollMode.DEFAULT) public var scrollMode:ScrollMode;
    @:clonable @:behaviour(ScrollPolicyBehaviour)                   public var scrollPolicy:ScrollPolicy;
    @:clonable @:behaviour(HScrollPolicyBehaviour)                  public var horizontalScrollPolicy:ScrollPolicy;
    @:clonable @:behaviour(VScrollPolicyBehaviour)                  public var verticalScrollPolicy:ScrollPolicy;
    @:clonable @:behaviour(GetContents)                             public var contents:Component;
    @:clonable @:behaviour(DefaultBehaviour)                        public var autoHideScrolls:Bool;
    @:clonable @:behaviour(DefaultBehaviour, true)                  public var allowAutoScroll:Bool;
    @:clonable @:behaviour(IsScrollableHorizontallyBehaviour)       public var isScrollableHorizontally:Bool;
    @:clonable @:behaviour(IsScrollableVerticallyBehaviour)         public var isScrollableVertically:Bool;
    @:clonable @:behaviour(IsScrollableBehaviour)                   public var isScrollable:Bool;
    @:clonable @:behaviour(EmptyContentsComponent)                  public var emptyContentsComponent:Component;
    @:clonable @:behaviour(EmptyContentsText)                       public var emptyContentsText:String;
    
    @:call(EnsureVisible)                                           public function ensureVisible(component:Component):Void;
    @:call(FindHorizontalScrollbar)                                 public function findHorizontalScrollbar():Component;
    @:call(FindVerticalScrollbar)                                   public function findVerticalScrollbar():Component;

    @:event(ScrollEvent.SCROLL)                                     public var onScroll:ScrollEvent->Void;
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateComponentInternal(nextFrame:Bool = true) { // TODO: can this be moved to CompositeBuilder? Like validateComponentLayout?
        if (native == true) { // TODO:  teeeeeemp! This should _absolutely_ be part of CompositeBuilder as native components try to call it and things like checkScrolls dont make sense
            super.validateComponentInternal(nextFrame);
            return;
        }
        var scrollInvalid = isComponentInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT);

        super.validateComponentInternal(nextFrame);

        if (scrollInvalid || layoutInvalid) {
            cast(_compositeBuilder, ScrollViewBuilder).checkScrolls(); // TODO: would be nice to not have this
            cast(_compositeBuilder, ScrollViewBuilder).updateScrollRect(); // TODO: or this
        }
    }
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class EnsureVisible extends DefaultBehaviour {
    public override function call(param:Any = null):Variant {
        var scrollview:ScrollView = cast(_component, ScrollView);
        if (scrollview.allowAutoScroll == false) {
            return null;
        }
        
        var c:Component = cast(param, Component);
        if (c == scrollview) {
            return null;
        }

        if (!scrollview.isReady) {
            scrollview.registerEvent(UIEvent.READY, function f(_) {
                scrollview.ensureVisible(c);
            });
            return null;
        }

        var hscroll:HorizontalScroll = scrollview.findComponent(HorizontalScroll, false);
        var hscrollPos:Float = 0;
        if (hscroll != null) {
            hscrollPos = hscroll.pos;
        }
        
        var vscroll:VerticalScroll = scrollview.findComponent(VerticalScroll, false);
        var vscrollPos:Float = 0;
        if (vscroll != null) {
            vscrollPos = vscroll.pos;
        }
        
        var componentScreenRect = new Rectangle(c.screenLeft, c.screenTop, c.width, c.height);
        var componentRect = new Rectangle(c.screenLeft + hscrollPos, c.screenTop + vscrollPos, c.width, c.height);
        var scrollRect = new Rectangle(scrollview.screenLeft, scrollview.screenTop, scrollview.width, scrollview.height);
        
        var scrollRectFixed = scrollRect.copy();
        var usableSize = scrollview.layout.usableSize;
        scrollRectFixed.width = usableSize.width;
        scrollRectFixed.height = usableSize.height;

        if (scrollRectFixed.containsRect(componentScreenRect)) { // fully contains child rect, do nothing
            return null;
        }
        
        var newHScrollPos = hscrollPos;
        var newVScrollPos = vscrollPos;
        
        var fixedRight = componentRect.right - scrollRect.left;
        var fixedLeft = componentRect.left - scrollRect.left;
        var fixedBottom = componentRect.bottom - scrollRect.top;
        var fixedTop = componentRect.top - scrollRect.top;
        var offsetLeft = 1;// contentsRect.left - scrollRect.left;
        var offsetTop = 1;// contentsRect.top - scrollRect.top;
        
        if (scrollRectFixed.containsPoint(componentScreenRect.right, componentScreenRect.top) == false) {
            newHScrollPos = fixedRight - (usableSize.width) + (calcOffset(c, "right") - offsetLeft);
        } else if (scrollRectFixed.containsPoint(componentScreenRect.left, componentScreenRect.top) == false) {
            newHScrollPos = fixedLeft - (calcOffset(c, "left") + offsetLeft);
        }
        
        if (scrollRectFixed.containsPoint(componentScreenRect.left, componentScreenRect.bottom) == false) {
            newVScrollPos = fixedBottom - (usableSize.height) + (calcOffset(c, "bottom") - offsetTop);
        } else if (scrollRectFixed.containsPoint(componentScreenRect.left, componentScreenRect.top) == false) {
            newVScrollPos = fixedTop - (calcOffset(c, "top") + offsetTop);
        }
        
        if (hscroll != null) {
            hscroll.pos = newHScrollPos;
        }
        if (vscroll != null) {
            vscroll.pos = newVScrollPos;
        }
        
        return null;
    }
    
    private function calcOffset(c:Component, which:String) {
        var p:Float = 0;
        var r = c.parentComponent;
        while (r != null) {
            if (r.style != null) {
                switch (which) {
                    case "left":
                        if (r.paddingLeft != null) {
                            p += r.paddingLeft;
                        }
                    case "right":
                        if (r.paddingRight != null) {
                            p += r.paddingRight;
                        }
                    case "top":
                        if (r.paddingTop != null) {
                            p += r.paddingTop;
                        }
                    case "bottom":
                        if (r.paddingBottom != null) {
                            p += r.paddingBottom;
                        }
                }
            }
            r = r.parentComponent;
            if (r == _component) {
                break;
            }
        }
        return p;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class FindHorizontalScrollbar extends DefaultBehaviour {
    public override function call(param:Any = null):Variant {
        var scrollview:ScrollView = cast(_component, ScrollView);
        return scrollview.findComponent(HorizontalScroll, false);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class FindVerticalScrollbar extends DefaultBehaviour {
    public override function call(param:Any = null):Variant {
        var scrollview:ScrollView = cast(_component, ScrollView);
        return scrollview.findComponent(VerticalScroll, false);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Virtual extends DefaultBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        if (_component._compositeBuilder != null) {
            cast(_component._compositeBuilder, ScrollViewBuilder).onVirtualChanged();
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.ScrollViewBuilder)
private class ContentLayoutName extends DefaultBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        var builder = cast(_component._compositeBuilder, ScrollViewBuilder);
        if (builder != null && builder._contentsLayoutName != value) {
            builder._contentsLayoutName = value;
            builder._contents.layout = LayoutFactory.createFromName(value);
        }
    }
}

@:dox(hide) @:noCompletion
private class ContentWidth extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return null;
        }
        return contents.width;
    }

    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.percentWidth = null;
            contents.width = value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class PercentContentWidth extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return null;
        }
        return contents.percentWidth;
    }

    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.componentWidth = null;
            contents.percentWidth = value;
        }
    }
}

@:dox(hide) @:noCompletion
private class ContentHeight extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return null;
        }
        return contents.height;
    }

    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.percentHeight = null;
            contents.height = value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class PercentContentHeight extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return null;
        }
        return contents.percentHeight;
    }

    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.componentHeight = null;
            contents.percentHeight = value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollPos extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var hscroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.pos;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        var hscroll = _scrollview.findComponent(HorizontalScroll, false);
        if (_scrollview.virtual == true) {
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            if (hscroll != null) {
                hscroll.pos = _value;
            }

        } else if (hscroll != null) {
            hscroll.pos = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollPos extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var vscroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.pos;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        var vscroll = _scrollview.findComponent(VerticalScroll, false);
        if (_scrollview.virtual == true) {
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            if (vscroll != null) {
                vscroll.pos = _value;
            }

        } else if (vscroll != null) {
            vscroll.pos = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollMax extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var hscroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.max;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var hscroll = _scrollview.findComponent(HorizontalScroll, false);
            if (_value > 0) {
                if (hscroll == null) {
                    hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
                }
            } else {
                if (hscroll != null) {
                    cast(_scrollview._compositeBuilder, ScrollViewBuilder).destroyHScroll();
                }
            }
            if (hscroll != null) {
                hscroll.max = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollMax extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var vscroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.max;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll, false);
            if (_value > 0) {
                if (vscroll == null) {
                    vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
                }
            } else {
                if (vscroll != null) {
                    cast(_scrollview._compositeBuilder, ScrollViewBuilder).destroyVScroll();
                }
            }
            if (vscroll != null) {
                vscroll.max = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollPageSize extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var hscroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.pageSize;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var hscroll = _scrollview.findComponent(HorizontalScroll, false);
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            if (hscroll != null) {
                hscroll.pageSize = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollThumbSize extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var hscroll = _scrollview.findComponent(HorizontalScroll, false);
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            if (hscroll != null) {
                hscroll.thumbSize = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollPageSize extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var vscroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.pageSize;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll, false);
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            if (vscroll != null) {
                vscroll.pageSize = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollThumbSize extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll, false);
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            if (vscroll != null) {
                vscroll.thumbSize = _value;
            }
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ThumbSize extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function validateData() { 
        _scrollview.hscrollThumbSize = _value;
        _scrollview.vscrollThumbSize = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ScrollModeBehaviour extends DataBehaviour {
    public override function set(value:Variant) {
        if (value == ScrollMode.HYBRID) {
            _component.isHybridScroller = true;
        } else if (value == ScrollMode.NATIVE) {
            _component.isNativeScroller = true;
        }
        super.set(value);
    }

    public override function validateData() {
        _component.registerInternalEvents(true);
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class IsScrollableHorizontallyBehaviour extends DefaultBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var hscroll = _scrollview.findComponent("scrollview-hscroll", HorizontalScroll);
        if (hscroll == null) { // seems we never need anything more (like checking the values of the scroll - if the scrollview cant scroll scrollbar is destroyed, and therefore null)
            return false;
        }
        return true;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class IsScrollableVerticallyBehaviour extends DefaultBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        var vscroll = _scrollview.findComponent("scrollview-vscroll", VerticalScroll);
        if (vscroll == null) { // seems we never need anything more (like checking the values of the scroll - if the scrollview cant scroll scrollbar is destroyed, and therefore null)
            return false;
        }
        return true;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class IsScrollableBehaviour extends DefaultBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function get():Variant {
        if (_scrollview.isScrollableVertically) { // more like to be scrolling vertically, so lets make that check first
            return true;
        }
        if (_scrollview.isScrollableHorizontally) {
            return true;
        }
        return false;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ScrollPolicyBehaviour extends DataBehaviour {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function validateData() {
        _scrollview.horizontalScrollPolicy = _value;
        _scrollview.verticalScrollPolicy = _value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollPolicyBehaviour extends DataBehaviour {
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollPolicyBehaviour extends DataBehaviour {
}

@:dox(hide) @:noCompletion
private class GetContents extends DefaultBehaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        return contents;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.ScrollViewBuilder)
private class EmptyContentsComponent extends DefaultBehaviour {
    public override function set(value:Variant):Void {
        super.set(value);
        var builder = cast(_component._compositeBuilder, ScrollViewBuilder);
        builder.checkEmptyContentsComponent();
    }
}


@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.ScrollViewBuilder)
private class EmptyContentsText extends DefaultBehaviour {
    public override function set(value:Variant):Void {
        super.set(value);
        var scrollview = cast(_component, ScrollView);
        var emptyContentsComponent = scrollview.emptyContentsComponent;
        if (emptyContentsComponent == null) {
            var emptyContentsComponent = scrollview.findComponent("empty-contents-component", false, "css");
            if (emptyContentsComponent == null) {
                emptyContentsComponent = new Label();
                emptyContentsComponent.addClass("empty-contents-component");
                emptyContentsComponent.text = value;
                scrollview.emptyContentsComponent = emptyContentsComponent;
            }
        } else if ((emptyContentsComponent is Label)) {
            emptyContentsComponent.text = value;
        } else {
            var label = emptyContentsComponent.findComponent(Label, true);
            if (label != null) {
                label.text = value;
            }
        }
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
typedef Inertia = {
    var screen:Point;
    var target:Point;
    var amplitude:Point;
    var direction:Point;
    var timestamp:Float;
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.backend.ComponentImpl)
class ScrollViewEvents extends haxe.ui.events.Events {
    private var _scrollview:ScrollView;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
    }

    public override function register() {
        var contents:Component = _scrollview.findComponent("scrollview-contents", false, "css");
        if (contents != null && contents.hasEvent(UIEvent.RESIZE, onContentsResized) == false) {
            contents.registerEvent(UIEvent.RESIZE, onContentsResized);
        }

        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll != null && hscroll.hasEvent(UIEvent.CHANGE, onHScroll) == false) {
            hscroll.registerEvent(UIEvent.CHANGE, onHScroll);
        }
        if (hscroll != null && hscroll.hasEvent(ScrollEvent.SCROLL, onHScrollScroll) == false) {
            hscroll.registerEvent(ScrollEvent.SCROLL, onHScrollScroll);
        }

        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll != null && vscroll.hasEvent(UIEvent.CHANGE, onVScroll) == false) {
            vscroll.registerEvent(UIEvent.CHANGE, onVScroll);
        }
        if (vscroll != null && vscroll.hasEvent(ScrollEvent.SCROLL, onVScrollScroll) == false) {
            vscroll.registerEvent(ScrollEvent.SCROLL, onVScrollScroll);
        }

        if (_scrollview.scrollMode == ScrollMode.DEFAULT || _scrollview.scrollMode == ScrollMode.DRAG || _scrollview.scrollMode == ScrollMode.INERTIAL || _scrollview.isHybridScroller) {
            registerEvent(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
            registerEvent(MouseEvent.MOUSE_DOWN, onLeftMouseDown);
            registerEvent(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
        } else if (hasEvent(MouseEvent.MOUSE_DOWN, onLeftMouseDown)) {
            unregisterEvent(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
            unregisterEvent(MouseEvent.MOUSE_DOWN, onLeftMouseDown);
            unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
        }

        if (_scrollview.hasEvent(UIEvent.SHOWN) == false) {
            registerEvent(UIEvent.SHOWN, onShown);
        }

        if (_scrollview.hasEvent(UIEvent.COMPONENT_ADDED) == false) {
            registerEvent(UIEvent.COMPONENT_ADDED, onComponentAdded);
        }

        if (contents != null && contents.hasEvent(UIEvent.COMPONENT_ADDED) == false) {
            contents.registerEvent(UIEvent.COMPONENT_ADDED, onContentsComponentAdded);
        }

        if (_scrollview.hasEvent(UIEvent.COMPONENT_REMOVED) == false) {
            registerEvent(UIEvent.COMPONENT_REMOVED, onComponentRemoved);
        }

        if (contents != null && contents.hasEvent(UIEvent.COMPONENT_REMOVED) == false) {
            contents.registerEvent(UIEvent.COMPONENT_REMOVED, onComponentRemoved);
        }

        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel, Priority.LOW);
        registerEvent(ActionEvent.ACTION_START, onActionStart, Priority.LOW);
    }

    public override function unregister() {
        var contents:Component = _scrollview.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.unregisterEvent(UIEvent.RESIZE, onContentsResized);
        }

        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            hscroll.unregisterEvent(UIEvent.CHANGE, onHScroll);
            hscroll.unregisterEvent(ScrollEvent.SCROLL, onHScrollScroll);
        }

        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.unregisterEvent(UIEvent.CHANGE, onVScroll);
            vscroll.unregisterEvent(ScrollEvent.SCROLL, onVScrollScroll);
        }

        unregisterEvent(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
        unregisterEvent(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
        unregisterEvent(MouseEvent.MOUSE_DOWN, onLeftMouseDown);
        unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        unregisterEvent(UIEvent.SHOWN, onShown);
        unregisterEvent(UIEvent.COMPONENT_ADDED, onComponentAdded);
        if (contents != null) {
            contents.unregisterEvent(UIEvent.COMPONENT_ADDED, onContentsComponentAdded);
        }
        unregisterEvent(UIEvent.COMPONENT_REMOVED, onComponentRemoved);
        if (contents != null) {
            contents.unregisterEvent(UIEvent.COMPONENT_REMOVED, onContentsComponentRemoved);
        }
        unregisterEvent(ActionEvent.ACTION_START, onActionStart);
    }

    private function onShown(event:UIEvent) {
        _scrollview.invalidateComponentLayout();
        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            hscroll.invalidateComponentLayout();
        }
        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.invalidateComponentLayout();
        }
    }

    private function onComponentAdded(event:UIEvent) { 
        if ((event.relatedComponent is Scroll)) {
            event.cancel();
            var scrollEvent = new ScrollEvent(ScrollEvent.CHANGE);
            _scrollview.dispatch(scrollEvent);
        }
    }

    private function onContentsComponentAdded(event:UIEvent) { 
        _scrollview.dispatch(event);
    }

    private function onComponentRemoved(event:UIEvent) { 
        if ((event.relatedComponent is Scroll)) {
            event.cancel();
            var scrollEvent = new ScrollEvent(ScrollEvent.CHANGE);
            _scrollview.dispatch(scrollEvent);
        }
    }

    private function onContentsComponentRemoved(event:UIEvent) { 
        _scrollview.dispatch(event);
    }

    private function onContentsResized(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
    }

    private function onHScroll(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
        _target.dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }

    private function onHScrollScroll(event:UIEvent) {
        _target.dispatch(new ScrollEvent(ScrollEvent.SCROLL));
    }

    private function onVScroll(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
        _target.dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }

    private function onVScrollScroll(event:UIEvent) {
        _target.dispatch(new ScrollEvent(ScrollEvent.SCROLL));
    }

    @:access(haxe.ui.core.Component)
    private function onLeftMouseDown(event:MouseEvent) {
        if (_scrollview.scrollMouseButton == MouseButton.LEFT) {
            onMouseDown(event);
        }
    }

    @:access(haxe.ui.core.Component)
    private function onMiddleMouseDown(event:MouseEvent) {
        if (_scrollview.scrollMouseButton == MouseButton.MIDDLE) {
            onMouseDown(event);
        }
    }

    @:access(haxe.ui.core.Component)
    private function onRightMouseDown(event:MouseEvent) {
        if (_scrollview.scrollMouseButton == MouseButton.RIGHT) {
            onMouseDown(event);
        }
    }
    
    private var _offset:Point;
    private static inline var INERTIAL_TIME_CONSTANT:Int = 325;
    private var _inertia:Inertia = null;
    @:access(haxe.ui.core.Component)
    private function onMouseDown(event:MouseEvent) {
        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);

        if (hscroll == null && vscroll == null) {
            return;
        }

        _scrollview.addClass(":down");

        _lastMousePos = new Point(event.screenX, event.screenY);

        var componentOffset = _scrollview.getComponentOffset();
        // we want to disallow mouse scrolling if we are under a textfield/textarea as this stops selection of data in textfield
        // if we are under a scrollbar, lets let the scroll bar handle it (rather than scrollview intefering) 
        var under = _scrollview.findComponentsUnderPoint(event.screenX - componentOffset.x, event.screenY - componentOffset.y);
        for (c in under) {
            if (c.hasTextInput() || (c is Scroll)) {
                return;
            }
        }

        //event.cancel();

        _offset = new Point();
        if (hscroll != null) {
            _offset.x = hscroll.pos + event.screenX;
        }
        if (vscroll != null) {
            _offset.y = vscroll.pos + event.screenY;
        }

        if (_scrollview.scrollMode == ScrollMode.INERTIAL) {
            if (_inertia == null) {
                _inertia = {
                    screen: new Point(),
                    target: new Point(),
                    amplitude: new Point(),
                    direction: new Point(),
                    timestamp: 0
                }
            }

            _inertia.target.x = _scrollview.hscrollPos;
            _inertia.target.y = _scrollview.vscrollPos;
            _inertia.amplitude.x = 0;
            _inertia.amplitude.y = 0;

            _inertia.screen.x = event.screenX;
            _inertia.screen.y = event.screenY;

            _inertia.timestamp = haxe.Timer.stamp();
        }

        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
        Screen.instance.registerEvent(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
        Screen.instance.registerEvent(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
    }

    private var _movementThreshold:Int = 3;
    private var _lastMousePos:Point = null;
    private function onMouseMove(event:MouseEvent) {
        event.cancel();
        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            hscroll.pos = _offset.x - event.screenX;
            var distX = Math.abs(event.screenX - _lastMousePos.x);
            #if haxeui_kha
            if (distX > 0) {
                pauseContainerEvents();
            }
            #else
            if (distX > Toolkit.scaleX) {
                pauseContainerEvents();
            }
            #end
        }
        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            vscroll.pos = _offset.y - event.screenY;
            var distY = Math.abs(event.screenY - _lastMousePos.y);
            #if haxeui_kha
            if (distY > 0) {
                pauseContainerEvents();
            }
            #else
            if (distY > Toolkit.scaleY) {
                pauseContainerEvents();
            }
            #end
        }
        _lastMousePos = new Point(event.screenX, event.screenY);
    }

    private var _containerEventsPaused:Bool = false;
    private function pauseContainerEvents() {
        if (_containerEventsPaused == true) {
            return;
        }
        _containerEventsPaused = true;
        onContainerEventsStatusChanged();
    }

    private function resumeContainerEvents() {
        if (_containerEventsPaused == false) {
            return;
        }

        _containerEventsPaused = false;
        onContainerEventsStatusChanged();
    }

    @:access(haxe.ui.core.Component)
    private function onContainerEventsStatusChanged() {
        var scrollViewContents = _scrollview.findComponent("scrollview-contents", Component, true, "css");
        scrollViewContents.disableInteractivity(_containerEventsPaused);

        if (_containerEventsPaused == true) {
            scrollViewContents.removeClass(":hover", true, true);
        } else {
            var components = scrollViewContents.findComponentsUnderPoint(Screen.instance.currentMouseX, Screen.instance.currentMouseY);
            for (c in components) {
                var mouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER);
                c.dispatch(mouseEvent);
            }
        }

        var hscroll = _scrollview.findComponent(HorizontalScroll, false);
        var vscroll = _scrollview.findComponent(VerticalScroll, false);
        if (hscroll != null || vscroll != null) {
            if (_scrollview.autoHideScrolls == true) {
                if (_containerEventsPaused == true) {
                    if (hscroll != null) {
                        //hscroll.hidden = false;
                        hscroll.fadeIn();
                    }
                    if (vscroll != null) {
                        //vscroll.hidden = false;
                        vscroll.fadeIn();
                    }
                } else {
                    if (hscroll != null) {
                        //hscroll.hidden = true;
                        hscroll.fadeOut();
                    }
                    if (vscroll != null) {
                        //vscroll.hidden = true;
                        vscroll.fadeOut();
                    }
                }
            }
        }
    }

    private function onMouseUp(event:MouseEvent) {
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onMouseUp);

        if (_scrollview.scrollMode == ScrollMode.INERTIAL) {
            var now = haxe.Timer.stamp();
            var elapsed = (now - _inertia.timestamp) * 1000;

            var deltaX = Math.abs(_inertia.screen.x - event.screenX);
            var deltaY = Math.abs(_inertia.screen.y - event.screenY);

            _inertia.direction.x = (_inertia.screen.x - event.screenX) < 0 ? 0 : 1;
            var velocityX = deltaX / elapsed;
            var v = 1000 * deltaX / (1 + elapsed);
            velocityX = 0.8 * v + 0.2 * velocityX;

            _inertia.direction.y = (_inertia.screen.y - event.screenY) < 0 ? 0 : 1;
            var velocityY = deltaY / elapsed;
            var v = 1000 * deltaY / (1 + elapsed);
            velocityY = 0.8 * v + 0.2 * velocityY;

            if (velocityX <= 75 && velocityY <= 75) {
                dispatch(new ScrollEvent(ScrollEvent.STOP));
                Toolkit.callLater(resumeContainerEvents);
                return;
            }

            _inertia.timestamp = haxe.Timer.stamp();

            var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
            if (hscroll != null) {
                _inertia.amplitude.x = 0.8 * velocityX;
            }
            if (_inertia.direction.x == 0) {
                _inertia.target.x = Math.round(_scrollview.hscrollPos - _inertia.amplitude.x);
            } else {
                _inertia.target.x = Math.round(_scrollview.hscrollPos + _inertia.amplitude.x);
            }

            var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
            if (vscroll != null) {
                _inertia.amplitude.y = 0.8 * velocityY;
            }
            if (_inertia.direction.y == 0) {
                _inertia.target.y = Math.round(_scrollview.vscrollPos - _inertia.amplitude.y);
            } else {
                _inertia.target.y = Math.round(_scrollview.vscrollPos + _inertia.amplitude.y);
            }

            if (_scrollview.hscrollPos == _inertia.target.x && _scrollview.vscrollPos == _inertia.target.y) {
                dispatch(new ScrollEvent(ScrollEvent.STOP));
                Toolkit.callLater(resumeContainerEvents);
                return;
            }

            if (_scrollview.hscrollPos == _inertia.target.x) {
                _inertia.amplitude.x = 0;
            }
            if (_scrollview.vscrollPos == _inertia.target.y) {
                _inertia.amplitude.y = 0;
            }

            Toolkit.callLater(inertialScroll);
        } else {
            _scrollview.removeClass(":down");
            dispatch(new ScrollEvent(ScrollEvent.STOP));
            Toolkit.callLater(resumeContainerEvents);
        }
    }

    private function inertialScroll() {
        var elapsed = (haxe.Timer.stamp() - _inertia.timestamp) * 1000;

        var finishedX = false;
        if (_inertia.amplitude.x != 0) {
            var deltaX = -_inertia.amplitude.x * Math.exp(-elapsed / INERTIAL_TIME_CONSTANT);
            if (deltaX > 0.5 || deltaX < -0.5) {
                var oldPos = _scrollview.hscrollPos;
                var newPos:Float = 0;
                if (_inertia.direction.x == 0) {
                    newPos = _inertia.target.x - deltaX;
                } else {
                    newPos = _inertia.target.x + deltaX;
                }
                if (newPos < 0) {
                    newPos = 0;
                } else if (newPos > _scrollview.hscrollMax) {
                    newPos = _scrollview.hscrollMax;
                }
                _scrollview.hscrollPos = newPos;
                finishedX = (newPos == oldPos || newPos == 0 || newPos == _scrollview.hscrollMax);
            } else {
                finishedX = true;
            }
        } else {
            finishedX = true;
        }

        var finishedY = false;
        if (_inertia.amplitude.y != 0) {
            var deltaY = -_inertia.amplitude.y * Math.exp(-elapsed / INERTIAL_TIME_CONSTANT);
            if (deltaY > 0.5 || deltaY < -0.5) {
                var oldPos = _scrollview.vscrollPos;
                var newPos:Float = 0;
                if (_inertia.direction.y == 0) {
                    newPos = _inertia.target.y - deltaY;
                } else {
                    newPos = _inertia.target.y + deltaY;
                }
                if (newPos < 0) {
                    newPos = 0;
                } else if (newPos > _scrollview.vscrollMax) {
                    newPos = _scrollview.vscrollMax;
                }
                _scrollview.vscrollPos = newPos;
                finishedY = (newPos == oldPos || newPos == 0 || newPos == _scrollview.vscrollMax);
            } else {
                finishedY = true;
            }
        } else {
            finishedY = true;
        }

        if (finishedX == true && finishedY == true) {
            dispatch(new ScrollEvent(ScrollEvent.STOP));
            Toolkit.callLater(resumeContainerEvents);
        } else {
            Toolkit.callLater(inertialScroll);
        }
    }

    private var _fadeTimer:Timer = null;
    @:access(haxe.ui.core.Component)
    private function onMouseWheel(event:MouseEvent) {
        if (_scrollview.isHybridScroller) {
            if (_scrollview.scrollPolicy == ScrollPolicy.NEVER) {
                return;
            }
            var primaryType:Class<Scroll> = VerticalScroll;
            var secondaryType:Class<Scroll> = HorizontalScroll;
            if (event.shiftKey) {
                primaryType = HorizontalScroll;
                secondaryType = VerticalScroll;
            }
            var scroll:Scroll = _scrollview.findComponent(primaryType, false);
            if (scroll == null) {
                scroll = _scrollview.findComponent(secondaryType, false);
            }
    
            if (_scrollview.autoHideScrolls == true && _fadeTimer == null && scroll != null) {
                scroll.fadeIn();
            }
            if (_scrollview.autoHideScrolls == true) {
                if (_fadeTimer != null) {
                    _fadeTimer.stop();
                    _fadeTimer = null;
                }
                _fadeTimer = new Timer(300, function() {
                    if (scroll != null) {
                        scroll.fadeOut();
                    }
                    _fadeTimer.stop();
                    _fadeTimer = null;
                });
            }
            return;
        }

        // we'll default to vertical scrolling for the mouse wheel, however,
        // if there is no vertical scrollbar we'll try to use horizontal
        // scrolling instead - note that if the shiftkey is pressed
        // we'll reverse that an look primarily to scroll horizontally
        if (_scrollview.scrollPolicy == ScrollPolicy.NEVER) {
            return;
        }
        var primaryType:Class<Scroll> = VerticalScroll;
        var secondaryType:Class<Scroll> = HorizontalScroll;
        if (event.shiftKey) {
            primaryType = HorizontalScroll;
            secondaryType = VerticalScroll;
        }
        var scroll:Scroll = _scrollview.findComponent(primaryType, false);
        if (scroll == null) {
            scroll = _scrollview.findComponent(secondaryType, false);
        }

        if (scroll != null) {
            var currentScrollPolicy = scroll.id == 'scrollview-vscroll'
            ? _scrollview.verticalScrollPolicy
            : _scrollview.horizontalScrollPolicy;

            if (currentScrollPolicy == ScrollPolicy.NEVER) {
              return;
            }

            if (_scrollview.autoHideScrolls == true && _fadeTimer == null) {
                scroll.fadeIn();
            }
            event.cancel();
            var amount = 50; // TODO: calculate this
            #if haxeui_pdcurses
            amount = 2;
            #end
            if (event.delta > 0) {
                scroll.pos -= amount;
            } else if (event.delta < 0) {
                scroll.pos += amount;
            }
            if (_scrollview.autoHideScrolls == true) {
                if (_fadeTimer != null) {
                    _fadeTimer.stop();
                    _fadeTimer = null;
                }
                _fadeTimer = new Timer(300, function() {
                    scroll.fadeOut();
                    _fadeTimer.stop();
                    _fadeTimer = null;
                });
            }
        }
    }
    
    private function onActionStart(event:ActionEvent) {
        if (_scrollview.scrollPolicy == ScrollPolicy.NEVER) {
            return;
        }
        switch (event.action) {
            case ActionType.DOWN:
                if (_scrollview.verticalScrollPolicy != ScrollPolicy.NEVER) {
                    _scrollview.vscrollPos++;
                    event.repeater = true;
                }
            case ActionType.UP:
                if (_scrollview.verticalScrollPolicy != ScrollPolicy.NEVER) {
                    _scrollview.vscrollPos--;
                    event.repeater = true;
                }
            case ActionType.LEFT:
                if (_scrollview.horizontalScrollPolicy != ScrollPolicy.NEVER) {
                    _scrollview.hscrollPos--;
                    event.repeater = true;
                }
            case ActionType.RIGHT:
                if (_scrollview.horizontalScrollPolicy != ScrollPolicy.NEVER) {
                    _scrollview.hscrollPos++;
                    event.repeater = true;
                }
            case _:
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.containers.ScrollView)
@:access(haxe.ui.core.Component)
class ScrollViewBuilder extends CompositeBuilder {
    private var _scrollview:ScrollView;
    private var _contents:Box;
    private var _contentsLayoutName:String;

    public function new(scrollview:ScrollView) {
        super(scrollview);
        _scrollview = scrollview;
        _scrollview.cascadeActive = true;
    }

    public override function create() {
        var contentLayoutName = _scrollview.contentLayoutName;
        if (contentLayoutName == null) {
            contentLayoutName = "vertical";
        }
        createContentContainer(contentLayoutName);
    }

    public override function destroy() {
    }

    private function checkEmptyContentsComponent(contentsComponent:Component = null) {
        if (_contents == null) {
            return;
        }

        var emptyContentsComponent:Component = _scrollview.emptyContentsComponent;
        if (emptyContentsComponent == null) {
            return;
        }

        if (contentsComponent == null) {
            contentsComponent = _contents;
        }

        var containsEmptyContentsComponent = _scrollview.containsChildComponent(emptyContentsComponent);
        if (contentsComponent.numComponents == 0) {
            if (!containsEmptyContentsComponent) {
                emptyContentsComponent.addClass("empty-contents-component");
                _scrollview.addComponent(emptyContentsComponent);
            }

            if (_scrollview.emptyContentsText != null) {
                if ((emptyContentsComponent is Label)) {
                    emptyContentsComponent.text = _scrollview.emptyContentsText;
                } else {
                    var label = emptyContentsComponent.findComponent(Label, true);
                    if (label != null) {
                        label.text = _scrollview.emptyContentsText;
                    }
                }                
            }

            emptyContentsComponent.show();
        } else if (containsEmptyContentsComponent) {
            emptyContentsComponent.hide();
        }
    }

    private override function get_numComponents():Null<Int> {
        return _contents.numComponents;
    }

    public override function addComponent(child:Component):Component {
        if (_scrollview.emptyContentsComponent == null && (child.id == "emptyContentsComponent" || child.hasClass("empty-contents-component"))) {
            _scrollview.emptyContentsComponent = child;
            return child;
        } else if (_scrollview.emptyContentsComponent != null && (child.id == "emptyContentsComponent" || child.hasClass("empty-contents-component")) && child != _scrollview.emptyContentsComponent) {
            _scrollview.removeComponent(_scrollview.emptyContentsComponent);
            _scrollview.emptyContentsComponent = child;
            return child;
        }

        if (_scrollview.emptyContentsComponent != null && child == _scrollview.emptyContentsComponent) {
            return null;
        }
        if ((child is HorizontalScroll) == false && (child is VerticalScroll) == false && child.hasClass("scrollview-contents") == false) {
            var contentsComponent = null;
            if ((child is Box)) {
                child.registerEvent(UIEvent.COMPONENT_ADDED, onContentsChanged);
                child.registerEvent(UIEvent.COMPONENT_REMOVED, onContentsChanged);
                contentsComponent = child;
            }
            var r = _contents.addComponent(child);
            checkEmptyContentsComponent(contentsComponent);
            return r;
        }
        return null;
    }

    public override function addComponentAt(child:Component, index:Int):Component {
        if ((child is HorizontalScroll) == false && (child is VerticalScroll) == false && child.hasClass("scrollview-contents") == false) {
            var r = _contents.addComponentAt(child, index);
            checkEmptyContentsComponent();
            return r;
        }
        return null;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (_scrollview.emptyContentsComponent != null && child == _scrollview.emptyContentsComponent) {
            return null;
        }
        if ((child is HorizontalScroll) == false && (child is VerticalScroll) == false && child.hasClass("scrollview-contents") == false) {
            var r = _contents.removeComponent(child, dispose, invalidate);
            checkEmptyContentsComponent();
            return r;
        }
        return null;
    }

    public override function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        var r = _contents.removeComponentAt(index, dispose, invalidate);
        checkEmptyContentsComponent();
        return r;
    }

    public override function removeAllComponents(dispose:Bool = true):Bool {
        _contents.removeAllComponents(dispose);
        checkEmptyContentsComponent();
        return true;
    }
    
    public override function getComponentIndex(child:Component):Int {
        return _contents.getComponentIndex(child);
    }

    public override function setComponentIndex(child:Component, index:Int):Component {
        if ((child is HorizontalScroll) == false && (child is VerticalScroll) == false && child.hasClass("scrollview-contents") == false) {
            return _contents.setComponentIndex(child, index);
        }
        return null;
    }

    public override function getComponentAt(index:Int):Component {
        return _contents.getComponentAt(index);
    }

    private function createContentContainer(layoutName:String) {
        if (_contents == null) {
            _contents = new Box();
            _contents.registerEvent(UIEvent.COMPONENT_ADDED, onContentsChanged);
            _contents.registerEvent(UIEvent.COMPONENT_REMOVED, onContentsChanged);
            _contents.addClass("scrollview-contents");
            _contents.id = "scrollview-contents";
            _contents.layout = LayoutFactory.createFromName(layoutName); // TODO: temp
            _component.addComponent(_contents);
            _contentsLayoutName = layoutName;
        }
    }

    private function onContentsChanged(event:UIEvent) { 
        checkEmptyContentsComponent(event.target);
    }

    private function horizontalConstraintModifier():Float {
        return 0;
    }

    private function verticalConstraintModifier():Float {
        return 0;
    }

    @:access(haxe.ui.backend.ComponentBase)
    private function checkScrolls() {
        if (_component.isNativeScroller == true) {
            return;
        }

        var usableSize:Size = _component.layout.usableSize;

        if (virtualHorizontal == false && usableSize.width > 0) {
            var horizontalConstraint = _contents;
            var hscroll:HorizontalScroll = _component.findComponent(HorizontalScroll, false);
            var vcw:Float = horizontalConstraint.width + horizontalConstraintModifier();
            if (vcw > usableSize.width) {
                if (hscroll == null) {
                    hscroll = createHScroll();
                }

                hscroll.max = vcw - usableSize.width;
                if (_scrollview.hscrollThumbSize == null) {
                    hscroll.pageSize = (usableSize.width / vcw) * hscroll.max;
                }

                hscroll.syncComponentValidation();    //avoid another pass
            } else if (_scrollview.horizontalScrollPolicy == ScrollPolicy.ALWAYS) {
                if (hscroll == null) {
                    hscroll = createHScroll();
                }
                hscroll.max = 0;
                hscroll.pageSize = 0;
            } else {
                if (_scrollview.horizontalScrollPolicy != ScrollPolicy.ALWAYS && hscroll != null) {
                    destroyHScroll();
                }
            }
        }

        if (virtualVertical == false && usableSize.height > 0) {
            var verticalConstraint = _contents;
            var vscroll:VerticalScroll = _component.findComponent(VerticalScroll, false);
            var vch:Float = verticalConstraint.height + verticalConstraintModifier();
            if (vch > usableSize.height) {
                if (vscroll == null) {
                    vscroll = createVScroll();
                }

                vscroll.max = vch - usableSize.height;
                if (_scrollview.vscrollThumbSize == null) {
                    vscroll.pageSize = (usableSize.height / vch) * vscroll.max;
                }

                vscroll.syncComponentValidation();    //avoid another pass
            } else if (_scrollview.verticalScrollPolicy == ScrollPolicy.ALWAYS) {
                if (vscroll == null) {
                    vscroll = createVScroll();
                }
                vscroll.max = 0;
                vscroll.pageSize = 0;
            } else {
                if (_scrollview.verticalScrollPolicy != ScrollPolicy.ALWAYS && vscroll != null) {
                    destroyVScroll();
                }
            }
        }
    }

    @:access(haxe.ui.backend.ComponentBase)
    public function createHScroll():HorizontalScroll {
        if (_component.isNativeScroller == true) {
            return null;
        }

        var usableSize:Size = _component.layout.usableSize;
        var horizontalConstraint = _contents;
        var hscroll:HorizontalScroll = _component.findComponent(HorizontalScroll, false);
        var vcw:Float = horizontalConstraint.width + horizontalConstraintModifier();

        if (usableSize.width <= 0) {
            return hscroll;
        }

        if (vcw > usableSize.width && hscroll == null || _scrollview.horizontalScrollPolicy == ScrollPolicy.ALWAYS) {
            hscroll = new HorizontalScroll();
            hscroll.includeInLayout = !_scrollview.autoHideScrolls;
            hscroll.hidden = _scrollview.autoHideScrolls;
            hscroll.percentWidth = 100;
            hscroll.allowFocus = false;
            hscroll.id = "scrollview-hscroll";
            if (_scrollview.hscrollThumbSize != null) {
                hscroll.thumbSize = _scrollview.hscrollThumbSize;
            }
            _component.addComponent(hscroll);
            _component.registerInternalEvents(true);
        }

        if (_scrollview.horizontalScrollPolicy == ScrollPolicy.NEVER) {
            hscroll.includeInLayout = false;
            hscroll.hidden = true;
        } else if (_scrollview.horizontalScrollPolicy == ScrollPolicy.ALWAYS) {
            hscroll.includeInLayout = true;
            hscroll.hidden = false;
        }

        return hscroll;
    }

    @:access(haxe.ui.backend.ComponentBase)
    public function createVScroll():VerticalScroll {
        if (_component.isNativeScroller == true) {
            return null;
        }

        var usableSize:Size = _component.layout.usableSize;
        var verticalConstraint = _contents;
        var vscroll:VerticalScroll = _component.findComponent(VerticalScroll, false);
        var vch:Float = verticalConstraint.height + verticalConstraintModifier();

        if (usableSize.height <= 0) {
            return vscroll;
        }

        if ((vch > usableSize.height && vscroll == null) || _scrollview.verticalScrollPolicy == ScrollPolicy.ALWAYS) {
            vscroll = new VerticalScroll();
            vscroll.includeInLayout = !_scrollview.autoHideScrolls;
            vscroll.hidden = _scrollview.autoHideScrolls;
            vscroll.percentHeight = 100;
            vscroll.allowFocus = false;
            vscroll.id = "scrollview-vscroll";
            if (_scrollview.vscrollThumbSize != null) {
                vscroll.thumbSize = _scrollview.vscrollThumbSize;
            }
            _component.addComponent(vscroll);
            _component.registerInternalEvents(true);
        }

        if (_scrollview.verticalScrollPolicy == ScrollPolicy.NEVER) {
            vscroll.includeInLayout = false;
            vscroll.hidden = true;
        } else if (_scrollview.verticalScrollPolicy == ScrollPolicy.ALWAYS) {
            vscroll.includeInLayout = true;
            vscroll.hidden = false;
        }

        return vscroll;
    }

    @:access(haxe.ui.backend.ComponentBase)
    public function destroyHScroll() {
        var hscroll:HorizontalScroll = _component.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            _component.removeComponent(hscroll);
        }
    }

    @:access(haxe.ui.backend.ComponentBase)
    public function destroyVScroll() {
        var vscroll:VerticalScroll = _component.findComponent(VerticalScroll, false);
        if (vscroll != null) {
            _component.removeComponent(vscroll);
        }
    }

    private function updateScrollRect() {
        if (_contents == null) {
            return;
        }

        var usableSize = _component.layout.usableSize;

        var clipCX = usableSize.width - horizontalConstraintModifier();
        if (clipCX > _contents.width) {
            clipCX = _contents.width + horizontalConstraintModifier();
        }
        var clipCY = usableSize.height - verticalConstraintModifier();
        if (clipCY > _contents.height) {
            clipCY = _contents.height + verticalConstraintModifier();
        }

        var xpos:Float = 0;
        var ypos:Float = 0;

        if (virtualHorizontal == false) {
            var hscroll = _component.findComponent(HorizontalScroll, false);
            if (hscroll != null) {
                xpos = hscroll.pos;
            }
        } else if (_contents.componentClipRect != null) {
            clipCX = _contents.componentClipRect.width;
        }

        if (virtualVertical == false) {
            var vscroll = _component.findComponent(VerticalScroll, false);
            if (vscroll != null) {
                ypos = vscroll.pos;
            }
        } else if (_contents.componentClipRect != null) {
            clipCY = _contents.componentClipRect.height;
        }

        var newClipRect:Rectangle = new Rectangle(Math.fround(xpos), Math.fround(ypos), Math.fround(clipCX), Math.fround(clipCY));
        _contents.componentClipRect = newClipRect;
        _contents.walkComponents(function(c) {
            // we dont usually check see if a component has an event before dispatching it
            // however, in this specific case we are going to, potentially, be disaptching
            // a move event for many child components, so lets just not do that if we know
            // the component isnt going to respond to that event anyway
            if (c.hasEvent(UIEvent.MOVE)) {
                c.dispatch(new UIEvent(UIEvent.MOVE));
            }
            return true;
        });
    }

    public var virtualHorizontal(get, null):Bool;
    private function get_virtualHorizontal():Bool {
        return _scrollview.virtual;
    }

    public var virtualVertical(get, null):Bool;
    private function get_virtualVertical():Bool {
        return _scrollview.virtual;
    }

    public function onVirtualChanged() {

    }

    public override function applyStyle(style:Style) {
        super.applyStyle(style);
        if (style.mode == "mobile") {
            _scrollview.autoHideScrolls = true;
        }
        
        if (style.contentWidth != null && style.contentWidth != _scrollview.contentWidth) {
            _scrollview.contentWidth = style.contentWidth;
        } else if (style.contentWidthPercent != null && style.contentWidthPercent != _scrollview.percentContentWidth) {
            _scrollview.percentContentWidth = style.contentWidthPercent;
        }
        
        if (style.contentHeight != null && style.contentHeight != _scrollview.contentHeight) {
            _scrollview.contentHeight = style.contentHeight;
        } else if (style.contentHeightPercent != null && style.contentHeightPercent != _scrollview.percentContentHeight) {
            _scrollview.percentContentHeight = style.contentHeightPercent;
        }
    }
}
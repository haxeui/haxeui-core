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
import haxe.ui.core.Platform;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IAxisDrag;
import haxe.ui.core.INestedScroll;
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
import haxe.ui.validation.ValidationManager;

@:composite(ScrollViewEvents, ScrollViewBuilder, ScrollViewLayout)
class ScrollView extends InteractiveComponent implements IScroller implements INestedScroll {
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
    
    /**
        How a scroll view keeps moving after a drag lets go (a fling), which differs between platforms, so a theme can
        set it: given the release velocity along one axis (units a second), the offset from where it let go `t`
        seconds later, and when it stops. By default it slows exponentially, with a time constant of 325 ms.
    **/
    public static var flingMotion:Float->FlingMotion = exponentialFling;

    /**
        What a touch drag or a fling past either end of a scroll view shows, which differs between platforms, so a
        theme can set it (Android's stretch, iOS's bounce). Null, the default, keeps the view at its ends.
    **/
    public static var overscroll:OverscrollEffect = null;

    /**
        Makes a scroll view's bars, which differ between themes, so a theme can give its own: a `VerticalScroll` or
        `HorizontalScroll` subclass that draws and behaves as it likes. Null, the default, makes HaxeUI's.
    **/
    public static var verticalScrollFactory:Void->VerticalScroll = null;
    public static var horizontalScrollFactory:Void->HorizontalScroll = null;

    // A scroll view inside this one shares its touch scrolling (INestedScroll): a drag's step it can't scroll at an
    // end, and a fling from that end, this one carries on with. A fling that scrolls it stops at its end.

    public function nestedScrollStart(vertical:Bool) {
        var builder = scrollEvents();
        if (builder != null) {
            builder.nestedStart();
        }
    }

    public function nestedPreScroll(vertical:Bool, delta:Float):Float {
        return 0;
    }

    public function nestedPostScroll(vertical:Bool, delta:Float):Float {
        var builder = scrollEvents();
        return builder != null ? builder.nestedScroll(vertical, delta) : 0;
    }

    public function nestedFling(vertical:Bool, velocity:Float):Bool {
        return false;
    }

    public function nestedFlingLeft(vertical:Bool, velocity:Float) {
        var builder = scrollEvents();
        if (builder != null) {
            builder.nestedFlingOn(vertical, velocity);
        }
    }

    private function scrollEvents():ScrollViewEvents {
        return Std.downcast(_internalEvents, ScrollViewEvents);
    }

    /**
        How far a touch drag that starts on a component taking drags along one axis (`IAxisDrag`, such as a slider)
        moves before the scroll view decides whose it is: along that axis it's the component's, across it the scroll
        view's. Android's touch slop, 8.
    **/
    public static var dragSlop:Float = 8;

    static function exponentialFling(velocity:Float):FlingMotion {
        var tau = 0.325;
        var distance = velocity * tau;
        // It stops with half a unit to go, too little to see.
        var duration = Math.abs(distance) > 0.5 ? tau * Math.log(Math.abs(distance) / 0.5) : 0;
        return {
            position: t -> t >= duration ? distance : distance * (1 - Math.exp(-t / tau)),
            velocity: t -> t >= duration ? 0 : velocity * Math.exp(-t / tau),
            duration: duration
        };
    }

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

        // Not laid out yet (focus given as a screen is added): no layout to measure by, which crashed on hxcpp.
        if (scrollview.layout == null) {
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
        
        // Up and down, the component counts as in view only with its containers' padding, as it's scrolled to show
        // it with that padding: tested without it, a component the view kept shrinking over (as the on-screen
        // keyboard slides up) stayed put until it was cut off, then jumped by the padding and more.
        var topOffset = calcOffset(c, "top");
        var bottomOffset = calcOffset(c, "bottom");
        var componentScreenRect = new Rectangle(c.screenLeft, c.screenTop - topOffset, c.width, c.height + topOffset + bottomOffset);
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
        
        if (scrollRectFixed.containsPoint(componentScreenRect.right, c.screenTop) == false) {
            newHScrollPos = fixedRight - (usableSize.width) + (calcOffset(c, "right") - offsetLeft);
        } else if (scrollRectFixed.containsPoint(componentScreenRect.left, c.screenTop) == false) {
            newHScrollPos = fixedLeft - (calcOffset(c, "left") + offsetLeft);
        }
        
        if (scrollRectFixed.containsPoint(componentScreenRect.left, componentScreenRect.bottom) == false) {
            newVScrollPos = fixedBottom - (usableSize.height) + (bottomOffset - offsetTop);
        } else if (scrollRectFixed.containsPoint(componentScreenRect.left, componentScreenRect.top) == false) {
            newVScrollPos = fixedTop - (topOffset + offsetTop);
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
/** A fling along one axis: the offset from where the drag let go, `t` seconds later, and when it stops. **/
typedef FlingMotion = {
    var position:Float->Float;
    /** Its velocity `t` seconds after it let go, in units a second: what it hands an overscroll effect at an end. **/
    @:optional var velocity:Float->Float;
    var duration:Float;
}

/**
    An overscroll effect (see `ScrollView.overscroll`). Distances are in units past the start (below 0) or the end
    (above 0) of the scrolled range along one axis; the effect shows them, and returns to rest by itself.
**/
interface OverscrollEffect {
    /** A drag holds the view `distance` past an end; 0 once it's back in range. **/
    function pull(scrollview:ScrollView, vertical:Bool, distance:Float):Void;
    /**
        The drag let go while past an end (`velocity` 0), or a fling reached an end at `velocity` units a second:
        the effect returns to rest.
    **/
    function release(scrollview:ScrollView, vertical:Bool, velocity:Float):Void;
    /** How far past an end it shows now, as a pull's distance, so a press there carries on from it; 0 at rest. **/
    function distance(scrollview:ScrollView, vertical:Bool):Float;
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

    // A touch drag that started on a component taking drags along one axis, until it moves far enough to tell whose
    // it is, and where it started.
    private var _axisDrag:IAxisDrag = null;
    // What the view sits in that shares a touch drag's vertical scrolling (INestedScroll), for the drag and its fling;
    // and the finger's travel, which measures the release speed while it shares, as the view may not have moved.
    private var _nested:INestedScroll = null;
    private var _flingNested:INestedScroll = null;
    private var _sampleFinger:Array<Float> = [];
    private var _downX:Float = 0;
    private var _downY:Float = 0;

    // The drag's last positions, to take its velocity from as it lets go: times in seconds, scroll positions.
    private static inline var SAMPLES:Int = 20;
    private var _sampleTimes:Array<Float> = [];
    private var _sampleX:Array<Float> = [];
    private var _sampleY:Array<Float> = [];

    // A fling under way: when it started, from where, and its motion along each axis (null for none).
    private var _flinging:Bool = false;
    private var _flingStart:Float = 0;
    private var _flingFromX:Float = 0;
    private var _flingFromY:Float = 0;
    private var _flingX:FlingMotion = null;
    private var _flingY:FlingMotion = null;
    private var _flingHScroll:Scroll = null;
    private var _flingVScroll:Scroll = null;

    // Android's ViewConfiguration: flings slower than this (units a second) don't happen, and faster ones are capped.
    private static inline var MIN_FLING_VELOCITY:Float = 50;
    private static inline var MAX_FLING_VELOCITY:Float = 8000;

    // A press that caught a fling: the fling's motion along each axis and when it started, and when the press came (-1
    // for none). A drag past the slop the fling's way within FLYWHEEL_TIME of the press is a flick that carries the
    // fling on (`_caughtFlick`): as it lets go, the speed the fling would have by then is added to its own, so a flick
    // never stops it, however lightly it ends, and flick after flick goes faster, as Android's list views do. A press
    // that stays put that long stops it, as does a flick back.
    private var _caughtX:FlingMotion = null;
    private var _caughtY:FlingMotion = null;
    private var _caughtStart:Float = 0;
    private var _caughtAt:Float = -1;
    private var _caughtFlick:Bool = false;
    private static inline var FLYWHEEL_TIME:Float = 0.1;

    @:access(haxe.ui.core.Component)
    private function onMouseDown(event:MouseEvent) {
        // A press stops a fling where it is, keeping its speed for a flick that follows.
        _caughtAt = -1;
        _caughtFlick = false;
        if (_flinging) {
            _caughtX = _flingX;
            _caughtY = _flingY;
            _caughtStart = _flingStart;
            _caughtAt = frameSeconds();
        }
        _flinging = false;
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
        _axisDrag = null;
        for (c in under) {
            // a component that drags along an axis (a slider) has a mouse drag to itself, and shares a touch drag by
            // its direction (see decideAxisDrag)
            if ((c is IAxisDrag) && !c.disabled) {
                var axis:IAxisDrag = cast c;
                if (axis.dragsAlong(true) || axis.dragsAlong(false)) {
                    if (!event.touchEvent) {
                        return;
                    }
                    _axisDrag = axis;
                }
            }
            // a press on a text input is its own, to select in it; with touch a single line lets the page scroll,
            // as on a phone, and selects with a long press instead
            if (c.hasTextInput() && (!event.touchEvent || c.getTextInput().multiline)) {
                return;
            }
            if (c is Scroll) {
                return;
            }
            // a mouse drag over selectable text selects it; a touch still scrolls
            if (!event.touchEvent && c.hasTextDisplay() && c.getTextDisplay().selectable) {
                return;
            }
        }

        // a touch drag inside something that takes drags along one axis (a pager of pages that scroll up and down) is
        // shared the same way, along an axis this view doesn't scroll itself (see decideAxisDrag)
        if (_axisDrag == null && event.touchEvent) {
            var outer = _scrollview.parentComponent;
            while (outer != null) {
                if ((outer is IAxisDrag) && !outer.disabled) {
                    var axis:IAxisDrag = cast outer;
                    if ((axis.dragsAlong(true) && hscroll == null) || (axis.dragsAlong(false) && vscroll == null)) {
                        _axisDrag = axis;
                    }
                    break;
                }
                outer = outer.parentComponent;
            }
        }

        // something it sits in may share a touch drag's vertical scrolling: a bottom sheet holding a list
        _nested = null;
        if (event.touchEvent && vscroll != null) {
            var outer = _scrollview.parentComponent;
            while (outer != null && _nested == null) {
                if (outer is INestedScroll) {
                    _nested = cast outer;
                    _nested.nestedScrollStart(true);
                }
                outer = outer.parentComponent;
            }
        }

        //event.cancel();

        _downX = event.screenX;
        _downY = event.screenY;
        _offset = new Point();
        if (hscroll != null) {
            _offset.x = hscroll.pos + caughtOverscroll(false, event) + event.screenX;
        }
        if (vscroll != null) {
            _offset.y = vscroll.pos + caughtOverscroll(true, event) + event.screenY;
        }

        _sampleTimes.resize(0);
        _sampleX.resize(0);
        _sampleY.resize(0);
        _sampleFinger.resize(0);
        _fingerY = event.screenY;
        addSample(hscroll, vscroll);

        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
        Screen.instance.registerEvent(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
        Screen.instance.registerEvent(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
    }

    // How far past an end the drag holds the view, along each axis (see ScrollView.overscroll).
    private var _overscrollX:Float = 0;
    private var _overscrollY:Float = 0;

    /** A touch press catches an overscroll effect that's returning to rest, and the drag carries on from it. **/
    private function caughtOverscroll(vertical:Bool, event:MouseEvent):Float {
        var effect = ScrollView.overscroll;
        var distance = (effect != null && event.touchEvent) ? effect.distance(_scrollview, vertical) : 0;
        if (distance != 0) {
            effect.pull(_scrollview, vertical, distance);
        }
        if (vertical) {
            _overscrollY = distance;
        } else {
            _overscrollX = distance;
        }
        return distance;
    }

    /** Sets `scroll` to the drag's `pos`, and shows how far past an end that is with the overscroll effect. **/
    private function dragTo(scroll:Scroll, pos:Float, vertical:Bool, touch:Bool) {
        scroll.pos = pos;
        var effect = ScrollView.overscroll;
        if (effect == null || !touch) {
            return;
        }
        var over = pos < scroll.min ? pos - scroll.min : (pos > scroll.max ? pos - scroll.max : 0);
        var was = vertical ? _overscrollY : _overscrollX;
        if (over != was) {
            effect.pull(_scrollview, vertical, over);
            if (vertical) {
                _overscrollY = over;
            } else {
                _overscrollX = over;
            }
        }
    }

    private var _movementThreshold:Int = 3;
    private var _lastMousePos:Point = null;
    private function onMouseMove(event:MouseEvent) {
        if (_axisDrag != null && !decideAxisDrag(event)) {
            return;
        }
        if (_caughtAt >= 0 && !_caughtFlick) {
            caughtMove(event);
        }
        event.cancel();
        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        if (hscroll != null) {
            dragTo(hscroll, _offset.x - event.screenX, false, event.touchEvent);
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
            if (_nested != null) {
                nestedStep(vscroll, _lastMousePos.y - event.screenY);
                _offset.y = vscroll.pos + event.screenY;
            } else {
                dragTo(vscroll, _offset.y - event.screenY, true, event.touchEvent);
            }
            _fingerY = event.screenY;
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
        addSample(hscroll, vscroll);
    }

    /**
        A touch drag that started on a component taking drags along one axis: once it has moved `dragSlop`, along that
        axis it's the component's and the scroll view lets go; across it, the scroll view takes it from here, without
        a jump. Returns whether the scroll view moves with it.
    **/
    private function decideAxisDrag(event:MouseEvent):Bool {
        var dx = Math.abs(event.screenX - _downX);
        var dy = Math.abs(event.screenY - _downY);
        if (Math.max(dx, dy) <= ScrollView.dragSlop) {
            return false;
        }
        var axis = _axisDrag;
        _axisDrag = null;
        if (axis.dragsAlong(dx > dy)) {
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
            Screen.instance.unregisterEvent(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
            Screen.instance.unregisterEvent(MouseEvent.RIGHT_MOUSE_UP, onMouseUp);
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onMouseUp);
            _scrollview.removeClass(":down");
            return false;
        }
        var hscroll:HorizontalScroll = _scrollview.findComponent(HorizontalScroll, false);
        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (hscroll != null) {
            _offset.x = hscroll.pos + _overscrollX + event.screenX;
        }
        if (vscroll != null) {
            _offset.y = vscroll.pos + _overscrollY + event.screenY;
        }
        _lastMousePos = new Point(event.screenX, event.screenY);
        _sampleTimes.resize(0);
        _sampleX.resize(0);
        _sampleY.resize(0);
        return true;
    }

    private function addSample(hscroll:HorizontalScroll, vscroll:VerticalScroll) {
        if (_sampleTimes.length == SAMPLES) {
            _sampleTimes.shift();
            _sampleX.shift();
            _sampleY.shift();
            _sampleFinger.shift();
        }
        _sampleTimes.push(frameSeconds());
        _sampleX.push(hscroll != null ? hscroll.pos : 0);
        _sampleY.push(vscroll != null ? vscroll.pos : 0);
        // As a scroll position: up as the finger moves up.
        _sampleFinger.push(-_fingerY);
    }

    private var _fingerY:Float = 0;

    /**
        A shared drag's step of `delta` (positive as the finger moves up): what it sits in takes its part first, the
        view scrolls by the rest within its range, and what's left at an end goes back to what it sits in.
    **/
    /** A drag began in a scroll view inside this one: this one's fling stops, as a touch on it would. **/
    public function nestedStart() {
        _flinging = false;
    }

    /** What a scroll view inside couldn't scroll at its end: this one scrolls by it, as far as it can. **/
    public function nestedScroll(vertical:Bool, delta:Float):Float {
        var scroll:Scroll = vertical ? _scrollview.findComponent(VerticalScroll, false) : _scrollview.findComponent(HorizontalScroll, false);
        if (scroll == null) {
            return 0;
        }
        var was = scroll.pos;
        scroll.pos = Math.max(scroll.min, Math.min(scroll.max, was + delta));
        return scroll.pos - was;
    }

    /** A fling of a scroll view inside that can't move it, from the end it heads for: this one flings instead. **/
    public function nestedFlingOn(vertical:Bool, velocity:Float) {
        var vscroll:VerticalScroll = _scrollview.findComponent(VerticalScroll, false);
        if (!vertical || vscroll == null || Math.abs(velocity) < MIN_FLING_VELOCITY) {
            return;
        }
        _flingHScroll = null;
        _flingVScroll = vscroll;
        _flingX = null;
        _flingY = ScrollView.flingMotion(velocity);
        _flingNested = null;
        _flinging = true;
        _flingStart = frameSeconds();
        _flingFromX = 0;
        _flingFromY = vscroll.pos;
        flingStep();
    }

    private function nestedStep(vscroll:VerticalScroll, delta:Float) {
        var rest = delta - _nested.nestedPreScroll(true, delta);
        var wanted = vscroll.pos + rest;
        var pos = Math.max(vscroll.min, Math.min(vscroll.max, wanted));
        vscroll.pos = pos;
        if (wanted != pos) {
            _nested.nestedPostScroll(true, wanted - pos);
        }
    }

    /**
        The drag's velocity as it let go, along x or y, in units a second, as Android's velocity tracker has it by
        default (LSQ2): a quadratic fitted by least squares to the positions in the 100 ms up to the last move, and its
        slope at that move, so a flick's speeding up at the end counts in full; 0 when it held still for the last 40 ms.
    **/
    private function releaseVelocity(positions:Array<Float>, now:Float):Float {
        var last = _sampleTimes.length - 1;
        if (last < 1 || now - _sampleTimes[last] > 0.04) {
            return 0;
        }
        var first = last;
        while (first > 0 && _sampleTimes[last] - _sampleTimes[first - 1] <= 0.1) {
            first--;
        }
        if (_sampleTimes[last] - _sampleTimes[first] < 0.001) {
            return 0;
        }
        // Times and positions from the last move's: x = a + b t + c t², and the velocity there is b.
        var s0 = 0.0, s1 = 0.0, s2 = 0.0, s3 = 0.0, s4 = 0.0, sx = 0.0, stx = 0.0, st2x = 0.0;
        for (i in first...last + 1) {
            var t = _sampleTimes[i] - _sampleTimes[last];
            var x = positions[i] - positions[last];
            s0 += 1;
            s1 += t;
            s2 += t * t;
            s3 += t * t * t;
            s4 += t * t * t * t;
            sx += x;
            stx += t * x;
            st2x += t * t * x;
        }
        var velocity:Float;
        var det = s0 * (s2 * s4 - s3 * s3) - s1 * (s1 * s4 - s2 * s3) + s2 * (s1 * s3 - s2 * s2);
        if (last - first >= 2 && Math.abs(det) > 1e-18) {
            velocity = (s0 * (stx * s4 - s3 * st2x) - sx * (s1 * s4 - s2 * s3) + s2 * (s1 * st2x - s2 * stx)) / det;
        } else {
            // Too few moves for a curve: a straight line through them.
            velocity = (s0 * stx - s1 * sx) / (s0 * s2 - s1 * s1);
        }
        return Math.max(-MAX_FLING_VELOCITY, Math.min(MAX_FLING_VELOCITY, velocity));
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
        // The deferred resume after a drag or fling can run once the scroll view's page has closed: nothing to resume.
        if (scrollViewContents == null) {
            return;
        }
        scrollViewContents.pauseInteractivity(_containerEventsPaused);

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
        _scrollview.removeClass(":down");

        // A touch drag flings, as on a phone; with the inertial mode any drag does.
        var mode = _scrollview.scrollMode;
        if (mode != ScrollMode.INERTIAL && (mode != ScrollMode.DEFAULT || !event.touchEvent)) {
            releaseOverscroll(false, 0);
            releaseOverscroll(true, 0);
        } else {
            var now = frameSeconds();
            _flingHScroll = _scrollview.findComponent(HorizontalScroll, false);
            _flingVScroll = _scrollview.findComponent(VerticalScroll, false);
            var vx = _flingHScroll != null ? releaseVelocity(_sampleX, now) : 0;
            var vy = _flingVScroll != null ? releaseVelocity(_nested != null ? _sampleFinger : _sampleY, now) : 0;
            if (_caughtFlick) {
                vx = flywheel(vx, speedOf(_caughtX, now - _caughtStart));
                vy = flywheel(vy, speedOf(_caughtY, now - _caughtStart));
            }
            _caughtAt = -1;
            _caughtFlick = false;
            // What the view sits in may take the fling, settling itself; otherwise it gets what's left at the top.
            _flingNested = _nested;
            if (_nested != null && _nested.nestedFling(true, vy)) {
                vy = 0;
            }
            // Let go past an end, the overscroll effect returns to rest; a flick back into range still flings.
            vx = releaseOverscroll(false, vx);
            vy = releaseOverscroll(true, vy);
            _flingX = Math.abs(vx) >= MIN_FLING_VELOCITY ? ScrollView.flingMotion(vx) : null;
            _flingY = Math.abs(vy) >= MIN_FLING_VELOCITY ? ScrollView.flingMotion(vy) : null;
            if (_flingX != null || _flingY != null) {
                // From the drag's last move, its time and place, so the fling carries straight on from it however
                // late the release, or the fling's first frame, comes.
                var last = _sampleTimes.length - 1;
                _flinging = true;
                _flingStart = _sampleTimes[last];
                _flingFromX = _sampleX[last];
                _flingFromY = _sampleY[last];
                // The release's frame moves on already, as the drag's frames did.
                flingStep();
                return;
            }
        }
        dispatch(new ScrollEvent(ScrollEvent.STOP));
        Toolkit.callLater(resumeContainerEvents);
    }

    /**
        A drag from a press that caught a fling: past the slop the fling's way within FLYWHEEL_TIME, it's a flick that
        carries the fling on; held longer, the press stopped it.
    **/
    private function caughtMove(event:MouseEvent) {
        if (frameSeconds() - _caughtAt > FLYWHEEL_TIME) {
            _caughtAt = -1;
            return;
        }
        var t = _caughtAt - _caughtStart;
        var vx = speedOf(_caughtX, t);
        var vy = speedOf(_caughtY, t);
        // As scroll distances: positive as the finger moves up or left, the content moving on.
        var dx = _downX - event.screenX;
        var dy = _downY - event.screenY;
        if ((dx * vx > 0 && Math.abs(dx) > ScrollView.dragSlop) || (dy * vy > 0 && Math.abs(dy) > ScrollView.dragSlop)) {
            _caughtFlick = true;
        }
    }

    /** A fling's speed `t` seconds in, 0 with none. **/
    private static function speedOf(motion:FlingMotion, t:Float):Float {
        return motion != null && motion.velocity != null ? motion.velocity(t) : 0;
    }

    /** A flick's `velocity` carrying on a caught fling going at `caught`: the two added, unless it flings back. **/
    private static function flywheel(velocity:Float, caught:Float):Float {
        if (caught == 0 || (velocity * caught < 0 && Math.abs(velocity) >= MIN_FLING_VELOCITY)) {
            return velocity;
        }
        return velocity * caught > 0 ? velocity + caught : caught;
    }

    /** The frame's time, in seconds: drag samples and flings are timed by the frames that show them. **/
    private static inline function frameSeconds():Float {
        return Platform.instance.frameTime() / 1000;
    }

    /**
        Lets go of a drag held past an end along one axis: the overscroll effect returns to rest, and `velocity` is
        what's left to fling, 0 unless it heads back into range.
    **/
    private function releaseOverscroll(vertical:Bool, velocity:Float):Float {
        var over = vertical ? _overscrollY : _overscrollX;
        if (over == 0 || ScrollView.overscroll == null) {
            return velocity;
        }
        if (vertical) {
            _overscrollY = 0;
        } else {
            _overscrollX = 0;
        }
        ScrollView.overscroll.release(_scrollview, vertical, 0);
        return (over > 0) == (velocity > 0) ? 0 : velocity;
    }

    /** Moves a fling on, once a frame, until it stops, reaches an end, or a press stops it. **/
    private function flingStep() {
        if (!_flinging) {
            return;
        }
        // Its page closed while it coasted: nothing left to move.
        if (@:privateAccess _scrollview._isDisposed) {
            _flinging = false;
            return;
        }
        var t = frameSeconds() - _flingStart;
        var movingX = _flingX != null && flingAxis(_flingX, _flingFromX, t, _flingHScroll);
        var movingY = _flingY != null && flingAxis(_flingY, _flingFromY, t, _flingVScroll);
        // The move shows in this frame, as a drag's does. Run from callLater, the validation it asks for would
        // otherwise wait for the next frame: a fling drew a frame late, then skipped frames.
        ValidationManager.instance.process();
        if (movingX || movingY) {
            Toolkit.callLater(flingStep);
            return;
        }
        _flinging = false;
        dispatch(new ScrollEvent(ScrollEvent.STOP));
        Toolkit.callLater(resumeContainerEvents);
    }

    /** Sets one axis's position `t` seconds into its fling, as a drag does, and says whether it moves on. **/
    private function flingAxis(motion:FlingMotion, from:Float, t:Float, scroll:Scroll):Bool {
        var pos = from + motion.position(t);
        // Only the end it heads for: a fling that starts at the top heading down leaves it, as one handed on from a
        // sheet to a list resting at its top does, rather than ending there before it moves.
        var heading = motion.position(motion.duration);
        var atEnd = (pos <= scroll.min && heading < 0) || (pos >= scroll.max && heading > 0);
        scroll.pos = Math.max(scroll.min, Math.min(scroll.max, pos));
        // A shared fling that reaches the top hands what's left to what the view sits in: a sheet carries on down. A
        // scroll view it sits in takes only a fling from the end it heads for, which this view can't move, the drag
        // having moved that one; a fling that scrolls this view stops at its end, as on its own.
        var handsOn = (_flingNested is ScrollView)
            ? (pos <= scroll.min && from <= scroll.min) || (pos >= scroll.max && from >= scroll.max)
            : pos <= scroll.min;
        if (atEnd && handsOn && t < motion.duration && _flingNested != null && (scroll is VerticalScroll)
            && motion.velocity != null) {
            _flingNested.nestedFlingLeft(true, motion.velocity(t));
            return false;
        }
        // A fling that reaches an end with speed to spare hands it to the overscroll effect.
        if (atEnd && t < motion.duration && ScrollView.overscroll != null && motion.velocity != null) {
            ScrollView.overscroll.release(_scrollview, scroll is VerticalScroll, motion.velocity(t));
        }
        return t < motion.duration && !atEnd;
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

            // At its end already, the wheel goes on to a scroll view around this one, as a browser's does.
            if ((event.delta < 0 && scroll.pos >= scroll.max) || (event.delta > 0 && scroll.pos <= scroll.min)) {
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
            hscroll = ScrollView.horizontalScrollFactory != null ? ScrollView.horizontalScrollFactory() : new HorizontalScroll();
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
            vscroll = ScrollView.verticalScrollFactory != null ? ScrollView.verticalScrollFactory() : new VerticalScroll();
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

        // The scroll position as it is: rounded to whole units here, the contents moved in steps of a whole dp, 2.75
        // device pixels on a phone, which showed at slow speeds. A backend rounds it to its own pixels.
        var newClipRect:Rectangle = new Rectangle(xpos, ypos, Math.fround(clipCX), Math.fround(clipCY));
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
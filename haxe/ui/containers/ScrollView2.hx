package haxe.ui.containers;

import haxe.ui.components.HorizontalScroll2;
import haxe.ui.components.VerticalScroll2;
import haxe.ui.constants.ScrollMode;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.DataBehaviour;
import haxe.ui.core.DefaultBehaviour;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.core.ScrollEvent;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.layouts.ScrollViewLayout;
import haxe.ui.util.Point;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;

@:composite(ScrollViewEvents, ScrollViewBuilder, ScrollViewLayout)
class ScrollView2 extends Component {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:behaviour(Virtual)                                public var virtual:Bool;
    @:behaviour(ContentWidth)                           public var contentWidth:Float;
    @:behaviour(PercentContentWidth)                    public var percentContentWidth:Float;
    @:behaviour(ContentHeight)                          public var contentHeight:Float;
    @:behaviour(PercentContentHeight)                   public var percentContentHeight:Float;
    @:behaviour(HScrollPos)                             public var hscrollPos:Float;
    @:behaviour(HScrollMax)                             public var hscrollMax:Float;
    @:behaviour(HScrollPageSize)                        public var hscrollPageSize:Float;
    @:behaviour(VScrollPos)                             public var vscrollPos:Float;
    @:behaviour(VScrollMax)                             public var vscrollMax:Float;
    @:behaviour(VScrollPageSize)                        public var vscrollPageSize:Float;
    @:behaviour(ScrollModeBehaviour, ScrollMode.DRAG)   public var scrollMode:ScrollMode;
    
    //***********************************************************************************************************
    // Validation
    //***********************************************************************************************************
    private override function validateComponentInternal() { // TODO: can this be moved to CompositeBuilder? Like validateComponentLayout?
        var scrollInvalid = isComponentInvalid(InvalidationFlags.SCROLL);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT);

        super.validateComponentInternal();

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
private class Virtual extends DefaultBehaviour {
    public override function set(value:Variant) {
        super.set(value);
        
        cast(_component._compositeBuilder, ScrollViewBuilder).onVirtualChanged();
    }
}

@:dox(hide) @:noCompletion
private class ContentWidth extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        return contents.width;
    }
    
    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        contents.width = value;
    }
}

@:dox(hide) @:noCompletion
private class PercentContentWidth extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        return contents.percentWidth;
    }
    
    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        contents.percentWidth = value;
    }
}

@:dox(hide) @:noCompletion
private class ContentHeight extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        return contents.height;
    }
    
    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        contents.height = value;
    }
}

@:dox(hide) @:noCompletion
private class PercentContentHeight extends Behaviour {
    public override function get():Variant {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        return contents.percentHeight;
    }
    
    public override function set(value:Variant) {
        var contents:Component = _component.findComponent("scrollview-contents", false, "css");
        contents.percentHeight = value;
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollPos extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function get():Variant {
        var hscroll = _scrollview.findComponent(HorizontalScroll2, false);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.pos;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        var hscroll = _scrollview.findComponent(HorizontalScroll2, false);
        if (_scrollview.virtual == true) {
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            hscroll.pos = _value;
            
        } else if (hscroll != null) {
            hscroll.pos = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollPos extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function get():Variant {
        var vscroll = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.pos;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        var vscroll = _scrollview.findComponent(VerticalScroll2, false);
        if (_scrollview.virtual == true) {
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            vscroll.pos = _value;
            
        } else if (vscroll != null) {
            vscroll.pos = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollMax extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function get():Variant {
        var hscroll = _scrollview.findComponent(HorizontalScroll2, false);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.max;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var hscroll = _scrollview.findComponent(HorizontalScroll2, false);
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            hscroll.max = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class VScrollMax extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function get():Variant {
        var vscroll = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.max;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var vscroll = _scrollview.findComponent(VerticalScroll2, false);
            if (vscroll == null) {
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            vscroll.max = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class HScrollPageSize extends DataBehaviour {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function validateData() { // TODO: feels a bit ugly!
        if (_scrollview.virtual == true) {
            var hscroll = _scrollview.findComponent(HorizontalScroll2, false);
            if (hscroll == null) {
                hscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createHScroll();
            }
            hscroll.pageSize = _value;
        }
    }
}

@:dox(hide) @:noCompletion
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
                vscroll = cast(_scrollview._compositeBuilder, ScrollViewBuilder).createVScroll();
            }
            vscroll.pageSize = _value;
        }
    }
}

@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class ScrollModeBehaviour extends DataBehaviour {
    public override function validateData() {
        _component.registerInternalEvents(true);
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
class ScrollViewEvents extends haxe.ui.core.Events {
    private var _scrollview:ScrollView2;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function register() {
        var contents:Component = _scrollview.findComponent("scrollview-contents", false, "css");
        if (contents != null && contents.hasEvent(UIEvent.RESIZE, onContentsResized) == false) {
            contents.registerEvent(UIEvent.RESIZE, onContentsResized);
        }
        
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        if (hscroll != null && hscroll.hasEvent(UIEvent.CHANGE, onHScroll) == false) {
            hscroll.registerEvent(UIEvent.CHANGE, onHScroll);
        }
        
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll != null && vscroll.hasEvent(UIEvent.CHANGE, onVScroll) == false) {
            vscroll.registerEvent(UIEvent.CHANGE, onVScroll);
        }
        
        if (_scrollview.scrollMode == ScrollMode.DRAG || _scrollview.scrollMode == ScrollMode.INERTIAL) {
            registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        } else if (hasEvent(MouseEvent.MOUSE_DOWN, onMouseDown) == false) {
            unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        registerEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    public override function unregister() {
        var contents:Component = _scrollview.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.unregisterEvent(UIEvent.RESIZE, onContentsResized);
        }
        
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        if (hscroll != null) {
            hscroll.unregisterEvent(UIEvent.CHANGE, onHScroll);
        }
        
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll != null) {
            vscroll.unregisterEvent(UIEvent.CHANGE, onVScroll);
        }
        
        unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        unregisterEvent(MouseEvent.MOUSE_WHEEL, onMouseWheel);
    }
    
    private function onContentsResized(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
    }
    
    private function onHScroll(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
        _target.dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }
    
    private function onVScroll(event:UIEvent) {
        _scrollview.invalidateComponent(InvalidationFlags.SCROLL);
        _target.dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }
    
    private var _offset:Point;
    private static inline var INERTIAL_TIME_CONSTANT = 325;
    private var _inertia:Inertia = null;
    private function onMouseDown(event:MouseEvent) {
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);

        if (hscroll == null && vscroll == null) {
            return;
        }
        
        event.cancel();
        if (hscroll != null && hscroll.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        if (vscroll != null && vscroll.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        
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
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
    }
    
    private function onMouseMove(event:MouseEvent) {
        var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
        if (hscroll != null) {
            hscroll.pos = _offset.x - event.screenX;
        }
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll != null) {
            vscroll.pos = _offset.y - event.screenY;
        }
    }
    
    private function onMouseUp(event:MouseEvent) {
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
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
                return;
            }
            
            _inertia.timestamp = haxe.Timer.stamp();

            var hscroll:HorizontalScroll2 = _scrollview.findComponent(HorizontalScroll2, false);
            if (hscroll != null) {
                _inertia.amplitude.x = 0.8 * velocityX;
            }
            if (_inertia.direction.x == 0) {
                _inertia.target.x = Math.round(_scrollview.hscrollPos - _inertia.amplitude.x);
            } else {
                _inertia.target.x = Math.round(_scrollview.hscrollPos + _inertia.amplitude.x);
            }
            
            var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
            if (vscroll != null) {
                _inertia.amplitude.y = 0.8 * velocityY;
            }
            if (_inertia.direction.y == 0) {
                _inertia.target.y = Math.round(_scrollview.vscrollPos - _inertia.amplitude.y);
            } else {
                _inertia.target.y = Math.round(_scrollview.vscrollPos + _inertia.amplitude.y);
            }
            
            if (_scrollview.hscrollPos == _inertia.target.x && _scrollview.vscrollPos == _inertia.target.y) {
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
            dispatch(new ScrollEvent(ScrollEvent.STOP));
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
        } else {
            Toolkit.callLater(inertialScroll);
        }
    }
    
    private function onMouseWheel(event:MouseEvent) {
        var vscroll:VerticalScroll2 = _scrollview.findComponent(VerticalScroll2, false);
        if (vscroll != null) {
            event.cancel();
            if (event.delta > 0) {
                vscroll.pos -= 50; // TODO: calculate this
            } else if (event.delta < 0) {
                vscroll.pos += 50;
            }
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.containers.ScrollView2)
@:access(haxe.ui.core.Component)
class ScrollViewBuilder extends CompositeBuilder {
    private var _scrollview:ScrollView2;
    private var _contents:Box;
    
    public function new(scrollview:ScrollView2) {
        super(scrollview);
        _scrollview = scrollview;
    }
    
    public override function create() {
        createContentContainer("vertical");
    }
    
    public override function destroy() {
    }
    
    public override function addComponent(child:Component):Component {
        if (Std.is(child, HorizontalScroll2) == false && Std.is(child, VerticalScroll2) == false && child.hasClass("scrollview-contents") == false) {
            return _contents.addComponent(child);
        }
        return null;
    }
    
    public override function addComponentAt(child:Component, index:Int):Component {
        if (Std.is(child, HorizontalScroll2) == false && Std.is(child, VerticalScroll2) == false && child.hasClass("scrollview-contents") == false) {
            return _contents.addComponentAt(child, index);
        }
        return null;
    }
    
    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        if (Std.is(child, HorizontalScroll2) == false && Std.is(child, VerticalScroll2) == false && child.hasClass("scrollview-contents") == false) {
            return _contents.removeComponent(child, dispose, invalidate);
        }
        return null;
    }
    
    public override function setComponentIndex(child:Component, index:Int):Component {
        if (Std.is(child, HorizontalScroll2) == false && Std.is(child, VerticalScroll2) == false && child.hasClass("scrollview-contents") == false) {
            return _contents.setComponentIndex(child, index);
        }
        return null;
    }
    
    private function createContentContainer(layoutName:String) {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.id = "scrollview-contents";
            _contents.layout = LayoutFactory.createFromName(layoutName); // TODO: temp
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
        if (horizontalConstraint.width > usableSize.width) {
            if (hscroll == null) {
                hscroll = createHScroll();
            }

            hscroll.max = horizontalConstraint.width - usableSize.width;
            hscroll.pageSize = (usableSize.width / horizontalConstraint.width) * hscroll.max;

            hscroll.syncComponentValidation();    //avoid another pass
        } else {
            if (hscroll != null) {
                _component.removeComponent(hscroll);
            }
        }

        var vscroll:VerticalScroll2 = _component.findComponent(VerticalScroll2, false);
        if (verticalConstraint.height > usableSize.height) {
            if (vscroll == null) {
                vscroll = createVScroll();
            }

            vscroll.max = verticalConstraint.height - usableSize.height;
            vscroll.pageSize = (usableSize.height / verticalConstraint.height) * vscroll.max;

            vscroll.syncComponentValidation();    //avoid another pass
        } else {
            if (vscroll != null) {
                _component.removeComponent(vscroll);
            }
        }
    }

    public function createHScroll():HorizontalScroll2 {
        var hscroll = new HorizontalScroll2();
        hscroll.percentWidth = 100;
        hscroll.id = "scrollview-hscroll";
        _component.addComponent(hscroll);
        _component.registerInternalEvents(true);
        return hscroll;
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
    
    public function onVirtualChanged() {
        
    }
}
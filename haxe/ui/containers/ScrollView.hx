package haxe.ui.containers;

import haxe.ui.core.Behaviour;
import haxe.ui.core.ScrollEvent;
import haxe.ui.components.HScroll;
import haxe.ui.components.VScroll;
import haxe.ui.constants.ScrollMode;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.Layout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;
import haxe.ui.util.Timer;
import haxe.ui.util.Variant;

@:dox(icon = "/icons/ui-scroll-pane-both.png")
class ScrollView extends Component {
    public var _contents:Box;
    private var _hscroll:HScroll;
    private var _vscroll:VScroll;

    public function new() {
        super();
    }

    private override function createLayout():Layout {
        return new ScrollViewLayout();
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "vscrollPos" => new DefaultVScrollPosBehaviour(this),
            "hscrollPos" => new DefaultHScrollPosBehaviour(this)
        ]);
    }

    private override function create() {
        super.create();
        if (native == true) {
            updateScrollRect();
        } else {
            checkScrolls();
            //updateScrollRect();
        }
    }

    private var _layoutName:String = "vertical";
    public var layoutName(get, set):String;
    private function get_layoutName():String {
        return _layoutName;
    }
    private function set_layoutName(value:String):String {
        if (_layoutName == value) {
            return value;
        }

        _layoutName = value;
        if (_contents != null) {
            _contents.layout = LayoutFactory.createFromName(layoutName);
        }
        return value;
    }

    private override function createChildren() {
        super.createChildren();
        registerEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        if (_scrollMode == ScrollMode.DRAG || _scrollMode == ScrollMode.INERTIAL) {
            registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        }
        createContentContainer();
    }

    private function createContentContainer() {
        if (_contents == null) {
            _contents = new Box();
            _contents.addClass("scrollview-contents");
            _contents.registerEvent(UIEvent.RESIZE, _onContentsResized);
            _contents.layout = LayoutFactory.createFromName(layoutName);
            addComponent(_contents);
        }
    }

    private override function destroyChildren() {
        if (_hscroll != null) {
            removeComponent(_hscroll);
            _hscroll = null;
        }
        if (_vscroll != null) {
            removeComponent(_vscroll);
            _vscroll = null;
        }
    }

    private override function onReady() {
        super.onReady();
        checkScrolls();
        updateScrollRect();
    }

    private override function onResized() {
        checkScrolls();
        updateScrollRect();
    }

    @bindable public var vscrollPos(get, set):Float;
    private function get_vscrollPos():Float {
        return behaviourGet("vscrollPos");
    }
    private function set_vscrollPos(value:Float):Float {
        behaviourSet("vscrollPos", value);
        handleBindings(["vscrollPos"]);
        return value;
    }

    @bindable public var hscrollPos(get, set):Float;
    private function get_hscrollPos():Float {
        return behaviourGet("hscrollPos");
    }
    private function set_hscrollPos(value:Float):Float {
        behaviourSet("hscrollPos", value);
        handleBindings(["hscrollPos"]);
        return value;
    }

    public var contentWidth(get, set):Null<Float>;
    private function get_contentWidth():Null<Float> {
        createContentContainer();
        if (_contents != null) {
            return _contents.width;
        }
        return null;
    }
    private function set_contentWidth(value:Null<Float>):Null<Float> {
        createContentContainer();
        if (_contents != null) {
            _contents.width = value;
        }
        return value;
    }

    public var contentHeight(get, set):Null<Float>;
    private function get_contentHeight():Null<Float> {
        createContentContainer();
        if (_contents != null) {
            return _contents.height;
        }
        return null;
    }
    private function set_contentHeight(value:Null<Float>):Null<Float> {
        createContentContainer();
        if (_contents != null) {
            _contents.height = value;
        }
        return value;
    }

    public var percentContentWidth(get, set):Null<Float>;
    private function get_percentContentWidth():Null<Float> {
        createContentContainer();
        if (_contents != null) {
            return _contents.percentWidth;
        }
        return null;
    }
    private function set_percentContentWidth(value:Null<Float>):Null<Float> {
        createContentContainer();
        if (_contents != null) {
            _contents.percentWidth = value;
        }
        return value;
    }

    public var percentContentHeight(get, set):Null<Float>;
    private function get_percentContentHeight():Null<Float> {
        createContentContainer();
        if (_contents != null) {
            return _contents.percentHeight;
        }
        return null;
    }
    private function set_percentContentHeight(value:Null<Float>):Null<Float> {
        createContentContainer();
        if (_contents != null) {
            _contents.percentHeight = value;
        }
        return value;
    }

    public override function addComponent(child:Component):Component {
        var v = null;
        if (Std.is(child, HScroll) || Std.is(child, VScroll) || child == _contents) {
            v = super.addComponent(child);
        } else {
            createContentContainer();
            v = _contents.addComponent(child);
        }
        return v;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        var v = null;
        if (Std.is(child, HScroll) || Std.is(child, VScroll) || child == _contents) {
            v = super.removeComponent(child, dispose, invalidate);
        } else if (_contents != null) {
            v = _contents.removeComponent(child, dispose, invalidate);
        }
        return v;
    }

    public function clearContents() {
        _contents.removeAllComponents();
    }

    private function addComponentToSuper(child:Component):Component {
        return super.addComponent(child);
    }

    public var contents(get, null):Component;
    private function get_contents():Component {
        return _contents;
    }

    /*
    private function _onScrollReady(event:UIEvent) {
        event.target.unregisterEvent(UIEvent.READY, _onScrollReady);
        checkScrolls();
        updateScrollRect();
    }
    */

    private var horizontalConstraint(get, null):Component;
    private function get_horizontalConstraint():Component {
        return _contents;
    }

    private var verticalConstraint(get, null):Component;
    private function get_verticalConstraint():Component {
        return _contents;
    }

    private function _onMouseWheel(event:MouseEvent) {
        if (_vscroll != null) {
            event.cancel();
            if (event.delta > 0) {
                _vscroll.pos -= 50; // TODO: calculate this
                //_vscroll.animatePos(_vscroll.pos - 50);
            } else if (event.delta < 0) {
                _vscroll.pos += 50;
            }
            dispatch(new ScrollEvent(ScrollEvent.CHANGE));
        }
    }

    private var _scrollMode:ScrollMode = ScrollMode.DRAG;
    public var scrollMode(get, set):ScrollMode;
    private function get_scrollMode():ScrollMode {
        return _scrollMode;
    }
    private function set_scrollMode(value:String):String {
        if (value == _scrollMode) {
            return value;
        }
        
        _scrollMode = value;
        if (_scrollMode == ScrollMode.DRAG || _scrollMode == ScrollMode.INERTIAL) {
            registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        } else {
            unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
        }
        
        return value;
    }

    private var __onScrollChange:ScrollEvent->Void;
    /**
     Utility property to add a single `ScrollEvent.CHANGE` event
    **/
    @:dox(group = "Event related properties and methods")
    public var onScrollChange(null, set):UIEvent->Void;
    private function set_onScrollChange(value:UIEvent->Void):UIEvent->Void {
        if (__onScrollChange != null) {
            unregisterEvent(ScrollEvent.CHANGE, __onScrollChange);
            __onScrollChange = null;
        }
        registerEvent(ScrollEvent.CHANGE, value);
        __onScrollChange = value;
        return value;
    }
    
    // ********************************************************************************
    // Inertial and drag scroll functions
    // ********************************************************************************
    
    private var _inertialTimestamp:Float;
    private static inline var INERTIAL_TIME_CONSTANT = 325;
    private var _inertialTimer:Timer;

    private var _offsetX:Float = 0;
    private var _screenOffsetX:Float;
    private var _inertialAmplitudeX:Float = 0;
    private var _inertialTargetX:Float = 0;
    private var _inertiaDirectionX:Int;
    
    private var _offsetY:Float = 0;
    private var _screenOffsetY:Float;
    private var _inertialAmplitudeY:Float = 0;
    private var _inertialTargetY:Float = 0;
    private var _inertiaDirectionY:Int;
    
    private function _onMouseDown(event:MouseEvent) {
        if ((_hscroll == null || _hscroll.hidden == true) && (_vscroll == null || _vscroll.hidden == true)) {
            return;
        }
        
        event.cancel();
        if (_hscroll != null && _hscroll.hidden == false && _hscroll.hitTest(event.screenX, event.screenY) == true) {
            return;
        }
        if (_vscroll != null && _vscroll.hidden == false && _vscroll.hitTest(event.screenX, event.screenY) == true) {
            return;
        }

        _offsetX = hscrollPos + event.screenX;
        _offsetY = vscrollPos + event.screenY;

        if (_scrollMode == ScrollMode.INERTIAL) {
            _inertialTargetX = hscrollPos;
            _inertialTargetY = vscrollPos;
            _inertialAmplitudeX = 0;
            _inertialAmplitudeY = 0;
            
            if (_inertialTimer != null) {
                _inertialTimer.stop();
                _inertialTimer = null;
            }
            
            _screenOffsetX = event.screenX;
            _screenOffsetY = event.screenY;
            
            _inertialTimestamp = haxe.Timer.stamp();
        }
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, _onMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, _onMouseUp);

        dispatch(new ScrollEvent(ScrollEvent.START));
    }
    
    private function _onMouseMove(event:MouseEvent) {
        hscrollPos = _offsetX - event.screenX;
        vscrollPos = _offsetY - event.screenY;
        dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }
    
    private function _onMouseUp(event:MouseEvent) {
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, _onMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, _onMouseUp);
        
        if (_scrollMode == ScrollMode.INERTIAL) {
            var now = haxe.Timer.stamp();
            var elapsed = (now - _inertialTimestamp) * 1000;
            
            var deltaX = Math.abs(_screenOffsetX - event.screenX);
            var deltaY = Math.abs(_screenOffsetY - event.screenY);

            _inertiaDirectionX = (_screenOffsetX - event.screenX) < 0 ? 0 : 1;
            var velocityX = deltaX / elapsed;
            var v = 1000 * deltaX / (1 + elapsed);
            velocityX = 0.8 * v + 0.2 * velocityX;
            
            _inertiaDirectionY = (_screenOffsetY - event.screenY) < 0 ? 0 : 1;
            var velocityY = deltaY / elapsed;
            var v = 1000 * deltaY / (1 + elapsed);
            velocityY = 0.8 * v + 0.2 * velocityY;

            if (velocityX <= 75 && velocityY <= 75) {
                return;
            }
            
            _inertialTimestamp = haxe.Timer.stamp();

            _inertialAmplitudeX = 0.8 * velocityX;
            if (_inertiaDirectionX == 0) {
                _inertialTargetX = Math.round(hscrollPos - _inertialAmplitudeX);
            } else {
                _inertialTargetX = Math.round(hscrollPos + _inertialAmplitudeX);
            }
            
            _inertialAmplitudeY = 0.8 * velocityY;
            if (_inertiaDirectionY == 0) {
                _inertialTargetY = Math.round(vscrollPos - _inertialAmplitudeY);
            } else {
                _inertialTargetY = Math.round(vscrollPos + _inertialAmplitudeY);
            }
            
            if (hscrollPos == _inertialTargetX && vscrollPos == _inertialTargetY) {
                return;
            }

            if (hscrollPos == _inertialTargetX) {
                _inertialAmplitudeX = 0;
            }
            if (vscrollPos == _inertialTargetY) {
                _inertialAmplitudeY = 0;
            }

            _inertialTimer = new Timer(10, inertialScroll); //TODO - FRAME event on demand
        } else {
            dispatch(new ScrollEvent(ScrollEvent.STOP));
        }
    }

    private function inertialScroll() {
        var elapsed = (haxe.Timer.stamp() - _inertialTimestamp) * 1000;

        var finishedX = false;
        if (_inertialAmplitudeX != 0) {
            var deltaX = -_inertialAmplitudeX * Math.exp(-elapsed / INERTIAL_TIME_CONSTANT);
            if (deltaX > 0.5 || deltaX < -0.5) {
                var oldPos = hscrollPos;
                if (_inertiaDirectionX == 0) {
                    hscrollPos = _inertialTargetX - deltaX;
                } else {
                    hscrollPos = _inertialTargetX + deltaX;
                }
                finishedX = hscrollPos == oldPos;
            } else {
                finishedX = true;
            }
        } else {
            finishedX = true;
        }

        var finishedY = false;
        if (_inertialAmplitudeY != 0) {
            var deltaY = -_inertialAmplitudeY * Math.exp(-elapsed / INERTIAL_TIME_CONSTANT);
            if (deltaY > 0.5 || deltaY < -0.5) {
                var oldPos = vscrollPos;
                if (_inertiaDirectionY == 0) {
                    vscrollPos = _inertialTargetY - deltaY;
                } else {
                    vscrollPos = _inertialTargetY + deltaY;
                }
                finishedY = vscrollPos == oldPos;
            } else {
                finishedY = true;
            }
        } else {
            finishedY = true;
        }

        if (finishedX == true && finishedY == true) {
            _inertialTimer.stop();
            _inertialTimer = null;

            dispatch(new ScrollEvent(ScrollEvent.STOP));
        }
    }
    
    private function _onContentsResized(event:UIEvent) {
        checkScrolls();
        updateScrollRect();
    }

    private var hscrollOffset(get, null):Float;
    private function get_hscrollOffset():Float {
        return 0;
    }

    public function checkScrolls() {
        if (isReady == false ||
            horizontalConstraint == null || horizontalConstraint.childComponents.length == 0 ||
            verticalConstraint == null || verticalConstraint.childComponents.length == 0 ||
            native == true) {
            return;
        }

        checkHScroll();
        checkVScroll();

        if (horizontalConstraint.componentWidth > layout.usableWidth) {
            if (_hscroll != null) {
                _hscroll.hidden = false;
                _hscroll.max = horizontalConstraint.componentWidth - layout.usableWidth - hscrollOffset; // _contents.layout.horizontalSpacing;
                _hscroll.pageSize = (layout.usableWidth / horizontalConstraint.componentWidth) * _hscroll.max;
            }
        } else {
            if (_hscroll != null) {
                _hscroll.hidden = true;
            }
        }

        if (verticalConstraint.componentHeight > layout.usableHeight) {
            if (_vscroll != null) {
                _vscroll.hidden = false;
                _vscroll.max = verticalConstraint.componentHeight - layout.usableHeight;
                _vscroll.pageSize = (layout.usableHeight / verticalConstraint.componentHeight) * _vscroll.max;
            }
        } else {
            if (_vscroll != null) {
                _vscroll.hidden = true;
            }
        }

        invalidateLayout();
    }

    private function checkHScroll() {
        if (componentWidth <= 0 || horizontalConstraint == null) {
            return;
        }

        if (horizontalConstraint.componentWidth > layout.usableWidth) {
            if (_hscroll == null) {
                _hscroll = new HScroll();
                _hscroll.percentWidth = 100;
                _hscroll.id = "scrollview-hscroll";
                _hscroll.registerEvent(UIEvent.CHANGE, _onScroll);
                addComponent(_hscroll);
            }
        } else {
            if (_hscroll != null) {
                removeComponent(_hscroll);
                _hscroll = null;
            }
        }
    }

    private function checkVScroll() {
        if (componentHeight <= 0 || verticalConstraint == null) {
            return;
        }

        if (verticalConstraint.componentHeight > layout.usableHeight) {
            if (_vscroll == null) {
                _vscroll = new VScroll();
                _vscroll.percentHeight = 100;
                _vscroll.id = "scrollview-vscroll";
                _vscroll.registerEvent(UIEvent.CHANGE, _onScroll);
                addComponent(_vscroll);
            }
        } else {
            if (_vscroll != null) { // TODO: bug in luxe backend
                removeComponent(_vscroll);
                _vscroll = null;
            }
        }
    }

    private function _onScroll(event:UIEvent) {
        updateScrollRect();
        handleBindings(["vscrollPos"]);
        dispatch(new ScrollEvent(ScrollEvent.CHANGE));
    }

    public function updateScrollRect() {
        if (_contents == null) {
            return;
        }

        var ucx = layout.usableWidth;
        var ucy = layout.usableHeight;

        var clipCX = ucx;
        if (clipCX > _contents.componentWidth) {
            clipCX = _contents.componentWidth;
        }
        var clipCY = ucy;
        if (clipCY > _contents.componentHeight) {
            clipCY = _contents.componentHeight;
        }

        var xpos:Float = 0;
        if (_hscroll != null) {
            xpos = _hscroll.pos;
        }
        var ypos:Float = 0;
        if (_vscroll != null) {
            ypos = _vscroll.pos;
        }

        var rc:Rectangle = new Rectangle(Std.int(xpos), Std.int(ypos), clipCX, clipCY);
        _contents.componentClipRect = rc;
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
class DefaultVScrollPosBehaviour extends Behaviour {
    public override function get():Variant {
        var vscroll:VScroll = _component.findComponent(VScroll);
        if (vscroll == null) {
            return 0;
        }
        return vscroll.pos;
    }
    
    public override function set(value:Variant) {
        var vscroll:VScroll = _component.findComponent(VScroll);
        if (vscroll != null) {
            vscroll.pos = value;
        }
    }
}

class DefaultHScrollPosBehaviour extends Behaviour {
    public override function get():Variant {
        var hscroll:HScroll = _component.findComponent(HScroll);
        if (hscroll == null) {
            return 0;
        }
        return hscroll.pos;
    }
    
    public override function set(value:Variant) {
        var hscroll:HScroll = _component.findComponent(HScroll);
        if (hscroll != null) {
            hscroll.pos = value;
        }
    }
}

//***********************************************************************************************************
// Layout
//***********************************************************************************************************
@:dox(hide)
class ScrollViewLayout extends DefaultLayout {
    public function new() {
        super();
    }

    private override function repositionChildren() {
        var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
        if (contents == null) {
            return;
        }

        var hscroll:Component = component.findComponent("scrollview-hscroll");
        var vscroll:Component = component.findComponent("scrollview-vscroll");

        var ucx = innerWidth;
        var ucy = innerHeight;

        if (hscroll != null && hidden(hscroll) == false) {
            hscroll.left = paddingLeft;
            hscroll.top = ucy - hscroll.componentHeight + paddingBottom;
        }

        if (vscroll != null && hidden(vscroll) == false) {
            vscroll.left = ucx - vscroll.componentWidth + paddingRight;
            vscroll.top = paddingTop;
        }

        contents.left = paddingLeft;
        contents.top = paddingTop;
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll:Component = component.findComponent("scrollview-hscroll");
        var vscroll:Component = component.findComponent("scrollview-vscroll");
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        if (cast(component, ScrollView).native == true) {
            var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
            if (contents != null && contents.componentHeight > size.height) {
                size.width -= Platform.vscrollWidth;
            }
            var contents:Component = component.findComponent("scrollview-contents", null, false, "css");
            if (contents != null && contents.componentWidth > size.width) {
                size.height -= Platform.hscrollHeight;
            }
        }

        return size;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var hscroll:Component = component.findComponent("scrollview-hscroll");
        var vscroll:Component = component.findComponent("scrollview-vscroll");
        var size:Size = super.calcAutoSize([hscroll, vscroll]);
        if (hscroll != null && hscroll.hidden == false) {
            size.height += hscroll.componentHeight;
        }
        if (vscroll != null && vscroll.hidden == false) {
            size.width += vscroll.componentWidth;
        }
        return size;
    }
}

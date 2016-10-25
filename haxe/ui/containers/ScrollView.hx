package haxe.ui.containers;

import haxe.ui.components.HScroll;
import haxe.ui.components.VScroll;
import haxe.ui.core.Component;
import haxe.ui.core.IClonable;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Platform;
import haxe.ui.core.UIEvent;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Size;

@:dox(icon="/icons/ui-scroll-pane-both.png")
class ScrollView extends Component implements IClonable<ScrollView> {
    public var _contents:Box;
    private var _hscroll:HScroll;
    private var _vscroll:VScroll;

    public function new() {
        super();
    }

    private override function createDefaults():Void {
        _defaultLayout = new ScrollViewLayout();
    }

    private override function create():Void {
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
    
    private override function createChildren():Void {
        super.createChildren();
        registerEvent(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
        _contents = new Box();
        _contents.addClass("scrollview-contents");
        _contents.registerEvent(UIEvent.RESIZE, _onContentsResized);
        _contents.layout = LayoutFactory.createFromName(layoutName);
        addComponent(_contents);
    }

    private override function destroyChildren():Void {
        if (_hscroll != null) {
            removeComponent(_hscroll);
            _hscroll = null;
        }
        if (_vscroll != null) {
            removeComponent(_vscroll);
            _vscroll = null;
        }
    }

    private override function onReady():Void {
        super.onReady();
        checkScrolls();
        updateScrollRect();
    }

    private override function onResized():Void {
        checkScrolls();
        updateScrollRect();
    }

    @bindable public var vscrollPos(get, set):Float;
    private function get_vscrollPos():Float {
        if (_vscroll == null) {
            return 0;
        }
        return _vscroll.pos;
    }
    private function set_vscrollPos(value:Float):Float {
        if (_vscroll == null) {
            return value;
        }
        _vscroll.pos = value;
        handleBindings(["vscrollPos"]);
        return value;
    }

    @bindable public var hscrollPos(get, set):Float;
    private function get_hscrollPos():Float {
        if (_hscroll == null) {
            return 0;
        }
        return _hscroll.pos;
    }
    private function set_hscrollPos(value:Float):Float {
        if (_hscroll == null) {
            return value;
        }
        _hscroll.pos = value;
        handleBindings(["hscrollPos"]);
        return value;
    }

    public var contentWidth(get, set):Null<Float>;
    private function get_contentWidth():Null<Float> {
        if (_contents != null) {
            return _contents.width;
        }
        return null;
    }
    private function set_contentWidth(value:Null<Float>):Null<Float> {
        if (_contents != null) {
            _contents.width = value;
        }
        return value;
    }
    
    public var contentHeight(get, set):Null<Float>;
    private function get_contentHeight():Null<Float> {
        if (_contents != null) {
            return _contents.height;
        }
        return null;
    }
    private function set_contentHeight(value:Null<Float>):Null<Float> {
        if (_contents != null) {
            _contents.height = value;
        }
        return value;
    }
    
    public var percentContentWidth(get, set):Null<Float>;
    private function get_percentContentWidth():Null<Float> {
        if (_contents != null) {
            return _contents.percentWidth;
        }
        return null;
    }
    private function set_percentContentWidth(value:Null<Float>):Null<Float> {
        if (_contents != null) {
            _contents.percentWidth = value;
        }
        return value;
    }
    
    public var percentContentHeight(get, set):Null<Float>;
    private function get_percentContentHeight():Null<Float> {
        if (_contents != null) {
            return _contents.percentHeight;
        }
        return null;
    }
    private function set_percentContentHeight(value:Null<Float>):Null<Float> {
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
            if (event.delta > 0) {
                _vscroll.pos -= 60; // TODO: calculate this
                //_vscroll.animatePos(_vscroll.pos - 60);
            } else if (event.delta < 0) {
                _vscroll.pos += 60;
            }
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
    
    public function checkScrolls():Void {
        if (isReady == false
            || horizontalConstraint == null || horizontalConstraint.childComponents.length == 0
            || verticalConstraint == null || verticalConstraint.childComponents.length == 0
            || native == true) {
            return;
        }

        checkHScroll();
        checkVScroll();

        if (horizontalConstraint.componentWidth > layout.usableWidth) {
            if (_hscroll != null) {
                _hscroll.hidden = false;
                _hscroll.max = horizontalConstraint.componentWidth - layout.usableWidth - hscrollOffset;// _contents.layout.horizontalSpacing;
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
        _contents.clipRect = rc;
    }
}

@:dox(hide)
class ScrollViewLayout extends DefaultLayout {
    public function new() {
        super();
    }

    private override function repositionChildren():Void {
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
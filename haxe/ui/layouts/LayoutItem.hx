package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

@:structInit
class LayoutItem {
    public var parentComponent:Component;
    public var layout:Layout;
    public var items:LayoutItems;
    public var component:Component;
    public var width:Null<Float>;
    public var percentWidth:Null<Float>;
    public var height:Null<Float>;
    public var percentHeight:Null<Float>;

    @:optional public var widthRoundingDirection:Null<Int>;

    public function resizeComponent(cx:Null<Float>, cy:Null<Float>) {
        if (width != null) {
            this.width = cx;
        }
        if (height != null) {
            this.height = cy;
        }
        component.resizeComponent(cx, cy);
    }

    public function moveComponent(x:Null<Float>, y:Null<Float>) {
        if (x != null) {
        }
        if (y != null) {
        }
        component.moveComponent(x, y);
    }

    @:optional private var _marginLeft:Null<Float> = null;
    @:optional public var marginLeft(get, null):Float;
    private function get_marginLeft():Float {
        if (_marginLeft != null) {
            return _marginLeft;
        }

        if (component.style == null || component.style.marginLeft == null) {
            _marginLeft = 0;
        } else {
            _marginLeft = component.style.marginLeft;
        }

        return _marginLeft;
    }

    @:optional private var _marginTop:Null<Float> = null;
    @:optional public var marginTop(get, null):Float;
    private function get_marginTop():Float {
        if (_marginTop != null) {
            return _marginTop;
        }

        if (component.style == null || component.style.marginTop == null) {
            _marginTop = 0;
        } else {
            _marginTop = component.style.marginTop;
        }

        return _marginTop;
    }

    @:optional private var _marginBottom:Null<Float> = null;
    @:optional public var marginBottom(get, null):Float;
    private function get_marginBottom():Float {
        if (_marginBottom != null) {
            return _marginBottom;
        }

        if (component.style == null || component.style.marginBottom == null) {
            _marginBottom = 0;
        } else {
            _marginBottom = component.style.marginBottom;
        }

        return _marginBottom;
    }

    @:optional private var _marginRight:Null<Float> = null;
    @:optional public var marginRight(get, null):Float;
    private function get_marginRight():Float {
        if (_marginRight != null) {
            return _marginRight;
        }

        if (component.style == null || component.style.marginRight == null) {
            _marginRight = 0;
        } else {
            _marginRight = component.style.marginRight;
        }

        return _marginRight;
    }

    @:optional private var _horizontalAlign:String = null;
    @:optional public var horizontalAlign(get, null):String;
    private function get_horizontalAlign():String {
        if (_horizontalAlign != null) {
            return _horizontalAlign;
        }

        if (component.style == null || component.style.horizontalAlign == null) {
            _horizontalAlign = "left";
        } else {
            _horizontalAlign = component.style.horizontalAlign;
        }

        return _horizontalAlign;
    }

    @:optional private var _verticalAlign:String = null;
    @:optional public var verticalAlign(get, null):String;
    private function get_verticalAlign():String {
        if (_verticalAlign != null) {
            return _verticalAlign;
        }

        if (component.style == null || component.style.verticalAlign == null) {
            _verticalAlign = "top";
        } else {
            _verticalAlign = component.style.verticalAlign;
        }

        return _verticalAlign;
    }

    @:optional private var _minWidth:Null<Float> = null;
    @:optional public var minWidth(get, null):Null<Float>;
    private function get_minWidth():Null<Float> {
        if (_minWidth != null) {
            return _minWidth;
        }

        if (component.style == null || component.style.minWidth == null) {
            _minWidth = null;
        } else {
            _minWidth = component.style.minWidth;
        }

        return _minWidth;
    }

    @:optional private var _maxWidth:Null<Float> = null;
    @:optional public var maxWidth(get, null):Null<Float>;
    private function get_maxWidth():Null<Float> {
        if (_maxWidth != null) {
            return _maxWidth;
        }

        if (component.style == null || component.style.maxWidth == null) {
            _maxWidth = null;
        } else {
            _maxWidth = component.style.maxWidth;
        }

        return _maxWidth;
    }

    private function innerSize() {
        var ucx:Float = 0;
        if (@:privateAccess parentComponent.componentWidth != null) {
            ucx = @:privateAccess parentComponent.componentWidth;
            ucx -= layout.paddingLeft + layout.paddingRight;
        }

        var ucy:Float = 0;
        if (@:privateAccess parentComponent.componentHeight != null) {
            ucy = @:privateAccess parentComponent.componentHeight;
            ucy -= layout.paddingTop + layout.paddingBottom;
        }

        return new Size(ucx, ucy);
    }

    @:optional private var _minHeight:Null<Float> = null;
    @:optional public var minHeight(get, null):Null<Float>;
    private function get_minHeight():Null<Float> {
        if (_minHeight != null) {
            return _minHeight;
        }

        if (component.style == null || component.style.minHeight == null) {
            _minHeight = null;
        } else {
            _minHeight = component.style.minHeight;
        }

        return _minHeight;
    }

    @:optional private var _maxHeight:Null<Float> = null;
    @:optional public var maxHeight(get, null):Null<Float>;
    private function get_maxHeight():Null<Float> {
        if (_maxHeight != null) {
            return _maxHeight;
        }

        if (component.style == null || component.style.maxHeight == null) {
            _maxHeight = null;
        } else {
            _maxHeight = component.style.maxHeight;
        }

        return _maxHeight;
    }

    @:optional private var _minPercentWidth:Null<Float> = null;
    @:optional public var minPercentWidth(get, null):Null<Float>;
    private function get_minPercentWidth():Null<Float> {
        if (_minPercentWidth != null) {
            return _minPercentWidth;
        }

        if (component.style == null || component.style.minPercentWidth == null) {
            _minPercentWidth = null;
        } else {
            _minPercentWidth = component.style.minPercentWidth;
        }

        return _minPercentWidth;
    }

    @:optional private var _maxPercentWidth:Null<Float> = null;
    @:optional public var maxPercentWidth(get, null):Null<Float>;
    private function get_maxPercentWidth():Null<Float> {
        if (_maxPercentWidth != null) {
            return _maxPercentWidth;
        }

        if (component.style == null || component.style.maxPercentWidth == null) {
            _maxPercentWidth = null;
        } else {
            _maxPercentWidth = component.style.maxPercentWidth;
        }

        return _maxPercentWidth;
    }

    @:optional private var _minPercentHeight:Null<Float> = null;
    @:optional public var minPercentHeight(get, null):Null<Float>;
    private function get_minPercentHeight():Null<Float> {
        if (_minPercentHeight != null) {
            return _minPercentHeight;
        }

        if (component.style == null || component.style.minPercentHeight == null) {
            _minPercentHeight = null;
        } else {
            _minPercentHeight = component.style.minPercentHeight;
        }

        return _minPercentHeight;
    }

    @:optional private var _maxPercentHeight:Null<Float> = null;
    @:optional public var maxPercentHeight(get, null):Null<Float>;
    private function get_maxPercentHeight():Null<Float> {
        if (_maxPercentHeight != null) {
            return _maxPercentHeight;
        }

        if (component.style == null || component.style.maxPercentHeight == null) {
            _maxPercentHeight = null;
        } else {
            _maxPercentHeight = component.style.maxPercentHeight;
        }

        return _maxPercentHeight;
    }

    public function reset() {
        _marginLeft = null;
        _marginTop = null;
        _marginRight = null;
        _marginBottom = null;
        _horizontalAlign = null;
        _verticalAlign = null;
        _minWidth = null;
        _maxWidth = null;
        _minHeight = null;
        _maxHeight = null;
        _minPercentWidth = null;
        _maxPercentWidth = null;
        _minPercentHeight = null;
        _maxPercentHeight = null;
        widthRoundingDirection = null;
    }
}
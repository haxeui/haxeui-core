package haxe.ui.layouts;

import haxe.ui.core.Component;

@:structInit
class LayoutItem {
    public var parentComponent:Component;
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
}
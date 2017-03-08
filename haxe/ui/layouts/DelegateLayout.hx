package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.util.Size;

class DelegateLayout extends DefaultLayout {
    private var _size:DelegateLayoutSize;

    public function new(size:DelegateLayoutSize) {
        super();
        _size = size;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        _size.component = component;

        var cx:Float = _size.width;
        var cy:Float = _size.height;
        if (_size.getBool("includePadding", false) == true) {
            cx += (paddingLeft + paddingRight);
            cy += (paddingTop + paddingBottom);
        }

        var size:Size = new Size(cx, cy);
        return size;
    }

    public override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        _size.component = component;
        size.width -= _size.usableWidthModifier;
        size.height -= _size.usableHeightModifier;
        return size;
    }
}

class DelegateLayoutSize {
    public function new() {
    }
    
    public var component:Component;
    public var config:Map<String, String>;

    public var width(get, null):Float;
    private function get_width():Float {
        return 0;
    }

    public var height(get, null):Float;
    private function get_height():Float {
        return 0;
    }

    public var usableWidthModifier(get, null):Float;
    private function get_usableWidthModifier():Float {
        return 0;
    }

    public var usableHeightModifier(get, null):Float;
    private function get_usableHeightModifier():Float {
        return 0;
    }

    public function getString(name:String, defaultValue:String = null):String {
        if (config == null) {
            return defaultValue;
        }
        if (config.exists(name) == false) {
            return defaultValue;
        }
        return config.get(name);
    }

    public function getInt(name:String, defaultValue:Int = 0):Int {
        var v = getString(name);
        if (v == null) {
            return defaultValue;
        }
        return Std.parseInt(v);
    }

    public function getBool(name:String, defaultValue:Bool = false):Bool {
        var v = getString(name);
        if (v == null) {
            return defaultValue;
        }
        return (v == "true");
    }
}
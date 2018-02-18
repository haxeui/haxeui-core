package haxe.ui.util;

class Rectangle {
    public var left(default, default):Float;
    public var top(default, default):Float;
    public var width(default, default):Float;
    public var height(default, default):Float;

    public function new(left:Float = 0, top:Float = 0, width:Float = 0, height:Float = 0) {
        this.left = left;
        this.top = top;
        this.width = width;
        this.height = height;
    }

    public var right(get, set):Float;
    private function get_right():Float {
        return left + width;
    }
    private function set_right(value:Float):Float {
        width = value - left;
        return value;
    }

    public var bottom(get, set):Float;
    private function get_bottom():Float {
        return top + height;
    }
    private function set_bottom(value:Float):Float {
        height = value - top;
        return value;
    }

    public function inflate(dx:Float, dy:Float) {
        left -= dx; width += dx * 2;
        top -= dy; height += dy * 2;
    }

    public function containsPoint(x:Float, y:Float):Bool {
        if (x >= left && x < left + width && y >= top && y < top + height) {
            return true;
        }
        return false;
    }
    
    public function toString():String {
        return "{left: " + left + ", top: " + top + ", bottom: " + bottom + ", right: " + right + ", width: " + width + ", height: " + height + "}";
    }
}
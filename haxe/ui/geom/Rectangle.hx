package haxe.ui.geom;

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
    
	public function containsRect(rect:Rectangle):Bool {
		if (rect.width <= 0 || rect.height <= 0) {
            return rect.left > left && rect.top > top && rect.right < right && rect.bottom < bottom;
        } else {
            return rect.left >= left && rect.top >= top && rect.right <= right && rect.bottom <= bottom;
        }
	}
    
    public function intersects(rect:Rectangle):Bool {
        var x0 = left < rect.left ? rect.left : left;
        var x1 = right > rect.right ? rect.right : right;

        if (x1 <= x0) {
            return false;
        }

        var y0 = top < rect.top ? rect.top : top;
        var y1 = bottom > rect.bottom ? rect.bottom : bottom;

        return y1 > y0;
    }
    
    
    public function toString():String {
        return "{left: " + left + ", top: " + top + ", bottom: " + bottom + ", right: " + right + ", width: " + width + ", height: " + height + "}";
    }
}
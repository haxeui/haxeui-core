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
	
	public var right(get, null):Float;
	private function get_right():Float {
		return left + width;
	}

	public var bottom(get, null):Float;
	private function get_bottom():Float {
		return top + height;
	}
	
	public function inflate(dx:Float, dy:Float):Void {
		left -= dx; width += dx * 2;
		top -= dy; height += dy * 2;
	}
	
	public function toString():String {
		return "{left: " + left + ", top: " + top + ", width: " + width + ", height: " + height + "}";
	}
}
package haxe.ui.util;

class MathUtil {
    public static inline var MAX_INT:Int = 2147483647; // 2**31 - 1
    public static inline var MIN_INT:Int = -2147483648;

    static public inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }
}
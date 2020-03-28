package haxe.ui.util;

class MathUtil {
    public static inline var MAX_INT:Int = 2147483647; // 2**31 - 1
    public static inline var MIN_INT:Int = -2147483648;

    public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }
    
    public static inline function round(v:Float, precision:Int = 0):Float {
        return Math.round(v * Math.pow(10, precision)) / Math.pow(10, precision);
    }
    
    public static inline function clamp(v:Null<Float>, min:Null<Float>, max:Null<Float>):Float {
        if (v == null || Math.isNaN(v)) {
            return min;
        }
        
        if (min != null && v < min) {
            v = min;
        } else if (max != null && v > max) {
            v = max;
        }
        
        return v;
    }
}
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

    public static inline function roundToNearest(v:Float, n:Float):Float {
        var r = v % n;
        if (r <= n / 2) {
            return Math.fround(v - r);
        }
        return Math.fround(v + n - r);
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
    
    public static inline function min(numbers:Array<Float>):Float {
        var r:Float = numbers[0];
        for (n in numbers) {
            if (n < r) {
                r = n;
            }
        }
        return r;
    }
    
    public static inline function max(numbers:Array<Float>):Float {
        var r:Float = numbers[0];
        for (n in numbers) {
            if (n > r) {
                r = n;
            }
        }
        return r;
    }
    
    public static inline function wrapCircular(v:Float, max:Float):Float {
        v = v % max;
        if (v < 0) {
            v += max;
        }
        return v;
    }
}
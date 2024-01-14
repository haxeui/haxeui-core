package haxe.ui.util;

class MathUtil {
    public static inline var MAX_INT:Int = 2147483647; // 2**31 - 1
    public static inline var MIN_INT:Int = -2147483648;
    public static inline var MAX_FLOAT_DIFFERENCE:Float = 0.0000001; // account for floating-point inaccuracy, 32 bit floats have 24 bits precision  log10(2**24) ≈ 7.225  (for 64 bits it's 15)

    public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }

    /**
        Precision is the number of significant decimal digits
        Returns a precision between 0 and 7
    **/
    public static inline function precision(v:Float):Int {
        var e = 1;
        var p = 0;
        while (Math.abs((Math.round(v * e) / e) - v) > MAX_FLOAT_DIFFERENCE) {
            e *= 10;
            p++;
        }
        return p;
    }

    public static inline function fmodulo(v1:Float, v2:Float):Float {
        if (!Math.isFinite(v1) || !Math.isFinite(v2)) {
            return Math.NaN;
        }
        var p = Std.int(Math.max(precision(v1), precision(v2)));
        var e = 1;
        for ( i in 0...p) {
            e *= 10;
        }
        var i1 = Math.round(v1 * e);
        var i2 = Math.round(v2 * e);
        return round(i1 % i2 / e, p);
    }

    public static inline function round(v:Float, precision:Int = 0):Float {
        return Math.fround(v * Math.pow(10, precision)) / Math.pow(10, precision);
    }

    public static inline function roundToNearest(v:Float, n:Float):Float {
        if (!Math.isFinite(v) || !Math.isFinite(n)) {
            return Math.NaN;
        }     
        var p = Std.int(Math.max(precision(v), precision(n)));
        var inv = 1.0 / n;
        return round(Math.fround(v * inv) / inv, p);
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
package haxe.ui.util;

class ColorUtil {
    public static function buildColorArray(startColor:Int, endColor:Int, size:Float):Array<Int> {
        var array:Array<Int> = [];

        var r1 = r(startColor);
        var g1 = g(startColor);
        var b1 = b(startColor);
        var r2 = r(endColor);
        var g2 = g(endColor);
        var b2 = b(endColor);
        var rd = r2 - r1; // deltas
        var gd = g2 - g1; // deltas
        var bd = b2 - b1; // deltas
        var ri:Float = rd / (size - 1); // increments
        var gi:Float = gd / (size - 1); // increments
        var bi:Float = bd / (size - 1); // increments

        var r:Float = r1;
        var g:Float = g1;
        var b:Float = b1;
        for (n in 0...cast size) {
            var c = color(r, g, b);
            array.push(c);

            r += ri;
            g += gi;
            b += bi;
        }

        return array;
    }

    public static inline function parseColor(s:String):Int {
        if (StringTools.startsWith(s, "#")) {
            s = s.substring(1, s.length);
        } else if (StringTools.startsWith(s, "0x")) {
            s = s.substring(2, s.length);
        }
        return Std.parseInt("0xFF" + s);
    }

    public static inline function color(r:Float, g:Float, b:Float):Int {
        return (Math.round(r) << 16) | (Math.round(g) << 8) | Math.round(b);
    }

    public static inline function r(c:Int):Int {
        return c >> 16 & 0xFF;
    }

    public static inline function g(c:Int):Int {
        return c >> 8 & 0xFF;
    }

    public static inline function b(c:Int):Int {
        return c & 0xFF;
    }
}
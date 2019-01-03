package haxe.ui.util;

class ColorUtil {
    public static function buildColorArray(startColor:Color, endColor:Color, size:Float):Array<Int> {
        var array:Array<Int> = [];

        var r1 = startColor.r;
        var g1 = startColor.g;
        var b1 = startColor.b;
        var r2 = endColor.r;
        var g2 = endColor.g;
        var b2 = endColor.b;
        var rd = r2 - r1; // deltas
        var gd = g2 - g1; // deltas
        var bd = b2 - b1; // deltas
        var ri:Float = rd / (size - 1); // increments
        var gi:Float = gd / (size - 1); // increments
        var bi:Float = bd / (size - 1); // increments

        var r:Float = r1;
        var g:Float = g1;
        var b:Float = b1;
        var c:Color;
        for (n in 0...cast size) {
            c.set(Math.round(r), Math.round(g), Math.round(b), 0);
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
        return Std.parseInt("0x" + s);
    }
}
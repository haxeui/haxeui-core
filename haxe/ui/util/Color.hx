package haxe.ui.util;

abstract Color(Int) from Int {
    @:from static public function fromString(s:String):Color {
        if (StringTools.startsWith(s, "0x") || StringTools.startsWith(s, "#")) {
            return Std.parseInt("0x" + s.substring(s.length - 6));
        }
        return switch (s) {
            case "black":   0x000000;
            case "red":     0xFF0000;
            case "lime":    0x00FF00;
            case "blue":    0x0000FF;
            case "white":   0xFFFFFF;
            case "aqua":    0x00FFFF;
            case "fuchsia": 0xFF00FF;
            case "yellow":  0xFFFF00;
            case "maroon":  0x800000;
            case "green":   0x008000;
            case "navy":    0x000080;
            case "olive":   0x808000;
            case "purple":  0x800080;
            case "teal":    0x008080;
            case "silver":  0xC0C0C0;
            case "gray", "grey": 0x808080;
            default: 0;
        }
    }

    static public function fromComponents(r:Int, g:Int, b:Int, a:Int):Color {
        var result:Color;
        return result.set(r, g, b, a);
    }

    public var r (get, set):Int;
    public var g (get, set):Int;
    public var b (get, set):Int;
    public var a (get, set):Int;

    private inline function get_r():Int {
        return (this >> 16) & 0xFF;
    }
    private inline function set_r(value:Int):Int {
        return set(value, g, b, a);
    }

    private inline function get_g():Int {
        return (this >> 8) & 0xFF;
    }
    private inline function set_g(value:Int):Int {
        return set(r, value, b, a);
    }

    private inline function get_b():Int {
        return this & 0xFF;
    }
    private inline function set_b(value:Int):Int {
        return set(r, g, value, a);
    }

    private inline function get_a():Int {
        return (this >> 24) & 0xFF;
    }
    private inline function set_a(value:Int):Int {
        return set(r, g, b, value);
    }

    public inline function set(r:Int, g:Int, b:Int, a:Int):Int {
        return this = ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
    }

    @:to function toInt():Int {
        return this;
    }

    @:op(A | B) static inline function or(a:Color, b:Color):Int {
        return a.toInt() | b.toInt();
    }

    @:op(A + B) static inline function sumColor(a:Color, b:Color):Int {
        return fromComponents(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a);
    }

    @:op(A - B) static inline function restColor(a:Color, b:Color):Int {
        return fromComponents(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a);
    }

    @:op(A - B) static inline function sumFloat(a:Color, b:Float):Int {
        var bInt:Int = Std.int(b);
        return fromComponents(a.r - bInt, a.g - bInt, a.b - bInt, a.a - bInt);
    }

    @:op(A * B) static inline function mulFloat(a:Color, b:Float):Int {
        return fromComponents(Std.int(a.r * b), Std.int(a.g * b), Std.int(a.b * b), Std.int(a.a * b));
    }
}

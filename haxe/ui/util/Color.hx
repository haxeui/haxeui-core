package haxe.ui.util;

abstract Color(Int) from Int {
    @:from static public function fromString(s:String):Color {
        if (StringTools.startsWith(s, "0x") || StringTools.startsWith(s, "#")) {
            return Std.parseInt("0x" + s.substring(s.length - 6));
        }
        return switch (s) {
            case "mediumvioletred":   0xc71585;
            case "deeppink":   0xff1493;
            case "palevioletred":   0xdb7093;
            case "hotpink":   0xff69b4;
            case "lightpink":   0xffb6c1;
            case "pink":   0xffc0cb;
            case "darkred":   0x8b0000;
            case "red":   0xff0000;
            case "firebrick":   0xb22222;
            case "crimson":   0xdc143c;
            case "indianred":   0xcd5c5c;
            case "lightcoral":   0xf08080;
            case "salmon":   0xfa8072;
            case "darksalmon":   0xe9967a;
            case "lightsalmon":   0xffa07a;
            case "orangered":   0xff4500;
            case "tomato":   0xff6347;
            case "darkorange":   0xff8c00;
            case "coral":   0xff7f50;
            case "orange":   0xffa500;
            case "darkkhaki":   0xbdb76b;
            case "gold":   0xffd700;
            case "khaki":   0xf0e68c;
            case "peachpuff":   0xffdab9;
            case "yellow":   0xffff00;
            case "palegoldenrod":   0xeee8aa;
            case "moccasin":   0xffe4b5;
            case "papayawhip":   0xffefd5;
            case "lightgoldenrodyellow":   0xfafad2;
            case "lemonchiffon":   0xfffacd;
            case "lightyellow":   0xffffe0;
            case "maroon":   0x800000;
            case "brown":   0xa52a2a;
            case "saddlebrown":   0x8b4513;
            case "sienna":   0xa0522d;
            case "chocolate":   0xd2691e;
            case "darkgoldenrod":   0xb8860b;
            case "peru":   0xcd853f;
            case "rosybrown":   0xbc8f8f;
            case "goldenrod":   0xdaa520;
            case "sandybrown":   0xf4a460;
            case "tan":   0xd2b48c;
            case "burlywood":   0xdeb887;
            case "wheat":   0xf5deb3;
            case "navajowhite":   0xffdead;
            case "bisque":   0xffe4c4;
            case "blanchedalmond":   0xffebcd;
            case "cornsilk":   0xfff8dc;
            case "darkgreen":   0x006400;
            case "green":   0x008000;
            case "darkolivegreen":   0x556b2f;
            case "forestgreen":   0x228b22;
            case "seagreen":   0x2e8b57;
            case "olive":   0x808000;
            case "olivedrab":   0x6b8e23;
            case "mediumseagreen":   0x3cb371;
            case "limegreen":   0x32cd32;
            case "lime":   0x00ff00;
            case "springgreen":   0x00ff7f;
            case "mediumspringgreen":   0x00fa9a;
            case "darkseagreen":   0x8fbc8f;
            case "mediumaquamarine":   0x66cdaa;
            case "yellowgreen":   0x9acd32;
            case "lawngreen":   0x7cfc00;
            case "chartreuse":   0x7fff00;
            case "lightgreen":   0x90ee90;
            case "greenyellow":   0xadff2f;
            case "palegreen":   0x98fb98;
            case "teal":   0x008080;
            case "darkcyan":   0x008b8b;
            case "lightseagreen":   0x20b2aa;
            case "cadetblue":   0x5f9ea0;
            case "darkturquoise":   0x00ced1;
            case "mediumturquoise":   0x48d1cc;
            case "turquoise":   0x40e0d0;
            case "aqua":   0x00ffff;
            case "cyan":   0x00ffff;
            case "aquamarine":   0x7fffd4;
            case "paleturquoise":   0xafeeee;
            case "lightcyan":   0xe0ffff;
            case "navy":   0x000080;
            case "darkblue":   0x00008b;
            case "mediumblue":   0x0000cd;
            case "blue":   0x0000ff;
            case "midnightblue":   0x191970;
            case "royalblue":   0x4169e1;
            case "steelblue":   0x4682b4;
            case "dodgerblue":   0x1e90ff;
            case "deepskyblue":   0x00bfff;
            case "cornflowerblue":   0x6495ed;
            case "skyblue":   0x87ceeb;
            case "lightskyblue":   0x87cefa;
            case "lightsteelblue":   0xb0c4de;
            case "lightblue":   0xadd8e6;
            case "powderblue":   0xb0e0e6;
            case "indigo":   0x4b0082;
            case "purple":   0x800080;
            case "darkmagenta":   0x8b008b;
            case "darkviolet":   0x9400d3;
            case "darkslateblue":   0x483d8b;
            case "blueviolet":   0x8a2be2;
            case "darkorchid":   0x9932cc;
            case "fuchsia":   0xff00ff;
            case "magenta":   0xff00ff;
            case "slateblue":   0x6a5acd;
            case "mediumslateblue":   0x7b68ee;
            case "mediumorchid":   0xba55d3;
            case "mediumpurple":   0x9370db;
            case "orchid":   0xda70d6;
            case "violet":   0xee82ee;
            case "plum":   0xdda0dd;
            case "thistle":   0xd8bfd8;
            case "lavender":   0xe6e6fa;
            case "mistyrose":   0xffe4e1;
            case "antiquewhite":   0xfaebd7;
            case "linen":   0xfaf0e6;
            case "beige":   0xf5f5dc;
            case "whitesmoke":   0xf5f5f5;
            case "lavenderblush":   0xfff0f5;
            case "oldlace":   0xfdf5e6;
            case "aliceblue":   0xf0f8ff;
            case "seashell":   0xfff5ee;
            case "ghostwhite":   0xf8f8ff;
            case "honeydew":   0xf0fff0;
            case "floralwhite":   0xfffaf0;
            case "azure":   0xf0ffff;
            case "mintcream":   0xf5fffa;
            case "snow":   0xfffafa;
            case "ivory":   0xfffff0;
            case "white":   0xffffff;
            case "black":   0x000000;
            case "darkslategray":   0x2f4f4f;
            case "dimgray":   0x696969;
            case "slategray":   0x708090;
            case "gray", "grey":   0x808080;
            case "lightslategray":   0x778899;
            case "darkgray":   0xa9a9a9;
            case "silver":   0xc0c0c0;
            case "lightgray":   0xd3d3d3;
            case "gainsboro":   0xdcdcdc;
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
        return this = ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
        //return this = ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
    }

    @:to public function toInt():Int {
        return this;
    }

    public function toHex():String {
        return "#" + StringTools.hex(r, 2) + StringTools.hex(g, 2) + StringTools.hex(b, 2);
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

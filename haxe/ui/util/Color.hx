package haxe.ui.util;

abstract Color(Int) from Int {
    private static var colors:Map<String, Int> = [
        "mediumvioletred" =>        0xc71585,
        "deeppink" =>               0xff1493,
        "palevioletred" =>          0xdb7093,
        "hotpink" =>                0xff69b4,
        "lightpink" =>              0xffb6c1,
        "pink" =>                   0xffc0cb,
        "darkred" =>                0x8b0000,
        "red" =>                    0xff0000,
        "firebrick" =>              0xb22222,
        "crimson" =>                0xdc143c,
        "indianred" =>              0xcd5c5c,
        "lightcoral" =>             0xf08080,
        "salmon" =>                 0xfa8072,
        "darksalmon" =>             0xe9967a,
        "lightsalmon" =>            0xffa07a,
        "orangered" =>              0xff4500,
        "tomato" =>                 0xff6347,
        "darkorange" =>             0xff8c00,
        "coral" =>                  0xff7f50,
        "orange" =>                 0xffa500,
        "darkkhaki" =>              0xbdb76b,
        "gold" =>                   0xffd700,
        "khaki" =>                  0xf0e68c,
        "peachpuff" =>              0xffdab9,
        "yellow" =>                 0xffff00,
        "palegoldenrod" =>          0xeee8aa,
        "moccasin" =>               0xffe4b5,
        "papayawhip" =>             0xffefd5,
        "lightgoldenrodyellow" =>   0xfafad2,
        "lemonchiffon" =>           0xfffacd,
        "lightyellow" =>            0xffffe0,
        "maroon" =>                 0x800000,
        "brown" =>                  0xa52a2a,
        "saddlebrown" =>            0x8b4513,
        "sienna" =>                 0xa0522d,
        "chocolate" =>              0xd2691e,
        "darkgoldenrod" =>          0xb8860b,
        "peru" =>                   0xcd853f,
        "rosybrown" =>              0xbc8f8f,
        "goldenrod" =>              0xdaa520,
        "sandybrown" =>             0xf4a460,
        "tan" =>                    0xd2b48c,
        "burlywood" =>              0xdeb887,
        "wheat" =>                  0xf5deb3,
        "navajowhite" =>            0xffdead,
        "bisque" =>                 0xffe4c4,
        "blanchedalmond" =>         0xffebcd,
        "cornsilk" =>               0xfff8dc,
        "darkgreen" =>              0x006400,
        "green" =>                  0x008000,
        "darkolivegreen" =>         0x556b2f,
        "forestgreen" =>            0x228b22,
        "seagreen" =>               0x2e8b57,
        "olive" =>                  0x808000,
        "olivedrab" =>              0x6b8e23,
        "mediumseagreen" =>         0x3cb371,
        "limegreen" =>              0x32cd32,
        "lime" =>                   0x00ff00,
        "springgreen" =>            0x00ff7f,
        "mediumspringgreen" =>      0x00fa9a,
        "darkseagreen" =>           0x8fbc8f,
        "mediumaquamarine" =>       0x66cdaa,
        "yellowgreen" =>            0x9acd32,
        "lawngreen" =>              0x7cfc00,
        "chartreuse" =>             0x7fff00,
        "lightgreen" =>             0x90ee90,
        "greenyellow" =>            0xadff2f,
        "palegreen" =>              0x98fb98,
        "teal" =>                   0x008080,
        "darkcyan" =>               0x008b8b,
        "lightseagreen" =>          0x20b2aa,
        "cadetblue" =>              0x5f9ea0,
        "darkturquoise" =>          0x00ced1,
        "mediumturquoise" =>        0x48d1cc,
        "turquoise" =>              0x40e0d0,
        "aqua" =>                   0x00ffff,
        "cyan" =>                   0x00ffff,
        "aquamarine" =>             0x7fffd4,
        "paleturquoise" =>          0xafeeee,
        "lightcyan" =>              0xe0ffff,
        "navy" =>                   0x000080,
        "darkblue" =>               0x00008b,
        "mediumblue" =>             0x0000cd,
        "blue" =>                   0x0000ff,
        "midnightblue" =>           0x191970,
        "royalblue" =>              0x4169e1,
        "steelblue" =>              0x4682b4,
        "dodgerblue" =>             0x1e90ff,
        "deepskyblue" =>            0x00bfff,
        "cornflowerblue" =>         0x6495ed,
        "skyblue" =>                0x87ceeb,
        "lightskyblue" =>           0x87cefa,
        "lightsteelblue" =>         0xb0c4de,
        "lightblue" =>              0xadd8e6,
        "powderblue" =>             0xb0e0e6,
        "indigo" =>                 0x4b0082,
        "purple" =>                 0x800080,
        "darkmagenta" =>            0x8b008b,
        "darkviolet" =>             0x9400d3,
        "darkslateblue" =>          0x483d8b,
        "blueviolet" =>             0x8a2be2,
        "darkorchid" =>             0x9932cc,
        "fuchsia" =>                0xff00ff,
        "magenta" =>                0xff00ff,
        "slateblue" =>              0x6a5acd,
        "mediumslateblue" =>        0x7b68ee,
        "mediumorchid" =>           0xba55d3,
        "mediumpurple" =>           0x9370db,
        "orchid" =>                 0xda70d6,
        "violet" =>                 0xee82ee,
        "plum" =>                   0xdda0dd,
        "thistle" =>                0xd8bfd8,
        "lavender" =>               0xe6e6fa,
        "mistyrose" =>              0xffe4e1,
        "antiquewhite" =>           0xfaebd7,
        "linen" =>                  0xfaf0e6,
        "beige" =>                  0xf5f5dc,
        "whitesmoke" =>             0xf5f5f5,
        "lavenderblush" =>          0xfff0f5,
        "oldlace" =>                0xfdf5e6,
        "aliceblue" =>              0xf0f8ff,
        "seashell" =>               0xfff5ee,
        "ghostwhite" =>             0xf8f8ff,
        "honeydew" =>               0xf0fff0,
        "floralwhite" =>            0xfffaf0,
        "azure" =>                  0xf0ffff,
        "mintcream" =>              0xf5fffa,
        "snow" =>                   0xfffafa,
        "ivory" =>                  0xfffff0,
        "white" =>                  0xffffff,
        "black" =>                  0x000000,
        "darkslategray" =>          0x2f4f4f,
        "dimgray" =>                0x696969,
        "slategray" =>              0x708090,
        "gray" =>                   0x808080,
        "grey" =>                   0x808080,
        "lightslategray" =>         0x778899,
        "darkgray" =>               0xa9a9a9,
        "silver" =>                 0xc0c0c0,
        "lightgray" =>              0xd3d3d3,
        "gainsboro" =>              0xdcdcdc
    ];

    static public function isValidColor(s:String):Bool {
        if (StringTools.startsWith(s, "#") && (s.length == 7 || s.length == 4)) {
            return true;
        } else if (StringTools.startsWith(s, "0x") && (s.length == 8)) { 
            return true;
        }
        
        return colors.exists(s);
    }

    @:from static public function fromString(s:String):Color {
        if (StringTools.startsWith(s, "0x") || StringTools.startsWith(s, "#")) {
            return Std.parseInt("0x" + s.substring(s.length - 6));
        }
        if (StringTools.startsWith(s, "#") && s.length == 4) {
            return Std.parseInt("0x" + s.substring(s.length - 3));
        }
        if (colors.exists(s)) {
            return colors.get(s);
        }
        return Std.parseInt(s);
    }

    static public function fromComponents(r:Int, g:Int, b:Int, a:Int):Color {
        var result:Color = 0;
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

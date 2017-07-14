package haxe.ui.util;

abstract Color(Int) from Int {
    @:from static function fromString(s:String):Color {
        if (StringTools.startsWith(s, "0x") || StringTools.startsWith(s, "#")) {
            return Std.parseInt("0x" + s.substring(s.length - 6));
        }
        return switch(s) {
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
    
    @:to function toInt():Int {
        return this;
    }
    
    @:op(A | B) static inline function or(a:Color, b:Color):Int {
        return a.toInt() | b.toInt();
    }
}

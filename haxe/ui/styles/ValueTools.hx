package haxe.ui.styles;

import haxe.ui.core.Platform;
import haxe.ui.constants.UnitTime;
import haxe.ui.core.Screen;
import haxe.ui.styles.StyleLookupMap;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

class ValueTools {
    private static var timeEReg:EReg = ~/^(-?\d+(?:\.\d+)?)(s|ms)$/gi;

    public static function parse(s:String):Value {
        var v = null;

        var hasSpace = (s.indexOf(" ") != -1);

        if (StringTools.endsWith(s, "%") == true && hasSpace == false) {
            v = Value.VDimension(Dimension.PERCENT(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "px") == true && hasSpace == false) {
            v = Value.VDimension(Dimension.PX(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "vw") == true && hasSpace == false) {
            v = Value.VDimension(Dimension.VW(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "vh") == true && hasSpace == false) {
            v = Value.VDimension(Dimension.VH(Std.parseFloat(s)));
        } else if (StringTools.endsWith(s, "rem") == true && hasSpace == false) {
            v = Value.VDimension(Dimension.REM(Std.parseFloat(s)));
        } else if (validColor(s)) {
            v = parseColor(s);
        } else if (s == "none") {
            v = Value.VNone;
        } else if (s.indexOf("(") != -1 && StringTools.endsWith(s, ")")) {
            var n = s.indexOf("(");
            var f = s.substr(0, n);
            var params = s.substr(n + 1, s.length - n - 2);
            if (f == "calc") {
                params = "'" + params + "'";
            }
            var vl = [];
            for (p in params.split(",")) {
                p = StringTools.trim(p);
                vl.push(parse(p));
            }
            v = Value.VCall(f, vl);
        } else if (StringTools.startsWith(s, "\"") && StringTools.endsWith(s, "\"")) {
            v = Value.VString(s.substr(1, s.length - 2));
        } else if (StringTools.startsWith(s, "'") && StringTools.endsWith(s, "'")) {
            v = Value.VString(s.substr(1, s.length - 2));
        } else if (isNum(s) == true) {
            v = Value.VNumber(Std.parseFloat(s));
        } else if (s == "true" || s == "false") {
            v = Value.VBool(s == "true");
        } else if (timeEReg.match(s)) {
            v = Value.VTime(Std.parseFloat(timeEReg.matched(1)), timeEReg.matched(2));
        } else {
            var arr = s.split(" ");
            if (arr.length == 1) {
                v = Value.VConstant(s);
            } else {
                var vl = [];
                for (a in arr) {
                    a = StringTools.trim(a);
                    vl.push(parse(a));
                }
                v = Value.VComposite(vl);
            }
        }

        return v;
    }

    public static function compositeParts(value:Value):Int {
        if (value == null) {
            return 0;
        }

        switch (value) {
            case Value.VComposite(vl):
                return vl.length;
            case _:
                return 0;
        }
    }

    public static function composite(value:Value):Array<Value> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VComposite(vl):
                return vl;
            case Value.VDimension(_) | Value.VNumber(_):
                return [value];
            case Value.VNone:
                return [];
            case _:
                return null;
        }

    }

    private static function isNum(s:String):Bool {
        var b = true;

        for (i in 0...s.length) {
            var c = s.charCodeAt(i);
            if (!((c >= '0'.code && c <= '9'.code) || c == '.'.code || c == '-'.code)) {
                b = false;
                break;
            }
        }

        return b;
    }

    private static var colors:Map<String, Int> = [
        "black"     => 0x000000,
        "red"       => 0xFF0000,
        "lime"      => 0x00FF00,
        "blue"      => 0x0000FF,
        "white"     => 0xFFFFFF,
        "aqua"      => 0x00FFFF,
        "fuchsia"   => 0xFF00FF,
        "yellow"    => 0xFFFF00,
        "maroon"    => 0x800000,
        "green"     => 0x008000,
        "navy"      => 0x000080,
        "olive"     => 0x808000,
        "purple"    => 0x800080,
        "teal"      => 0x008080,
        "silver"    => 0xC0C0C0,
        "gray"      => 0x808080,
        "grey"      => 0x808080
    ];

    private static function parseColor(s:String):Value {
        if (StringTools.startsWith(s, "#")) {
            s = s.substring(1);
            if (s.length == 6) {
                return Value.VColor(Std.parseInt("0x" + s));
            } else if (s.length == 3) {
                return Value.VColor(Std.parseInt("0x" + s.charAt(0) + s.charAt(0)
                                                      + s.charAt(1) + s.charAt(1)
                                                      + s.charAt(2) + s.charAt(2)));
            }
        } else if (colors.exists(s)) {
            return Value.VColor(colors.get(s));
        }

        return null;
    }

    private static function validColor(s:String):Bool {
        if (StringTools.startsWith(s, "#") && (s.length == 7 || s.length == 4)) {
            return true;
        } else if (colors.exists(s)) {
            return true;
        } /* else if (StringTools.startsWith(s, "rgb(")) {
            return true;
        } */

        return false;
    }

    public static function time(value:Value):Null<Float> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VTime(v, unit):
                switch (unit) {
                    case UnitTime.SECONDS:
                        return v;
                    case UnitTime.MILLISECONDS:
                        return v / 1000;
                    case _:
                        return null;
                }
            case _:
                return null;
        }
    }

    public static function variant(value:Value):Variant {
        if (value == null) {
            return null;
        }
        
        switch (value) {
            case Value.VString(v) | Value.VConstant(v):
                return Variant.fromDynamic(v);
            case Value.VNumber(v):
                return Variant.fromDynamic(v);
            case Value.VBool(v):
                return Variant.fromDynamic(v);
            case Value.VCall(f, vl):
                return Variant.fromDynamic(call(f, vl));
            case _:
                return null;
        }
    }
    
    public static function string(value:Value):String {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VString(v) | Value.VConstant(v):
                return v;
            case Value.VBool(v):
                return Std.string(v);
            case Value.VCall(f, vl):
                return call(f, vl);
            case _:
                return null;
        }
    }

    public static function bool(value:Value):Null<Bool> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VBool(v):
                return v;
            case _:
                return null;
        }
    }

    public static function none(value:Value):Null<Bool> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VNone:
                return true;
            case _:
                return null;
        }
    }
    
    public static function int(value:Value):Null<Int> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VColor(v):
                return v;
            case Value.VNumber(v):
                return Std.int(v);
            case Value.VNone:
                return null;
            case Value.VCall(f, vl):
                return call(f, vl);
            case _:
                return null;
        }
    }

    public static function float(value:Value):Null<Float> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VNumber(v):
                return v;
            case Value.VColor(v):
                return v;
            case Value.VNone:
                return null;
            case _:
                return null;
        }
    }

    public static function any(v:Value):Any {
        if (v == null) {
            return null;
        }

        switch (v) {
            case Value.VNumber(v):
                return v;
            case Value.VDimension(PX(v)):
                return v;
            case Value.VColor(v):
                return v;
            case Value.VBool(v):
                return v;
            case _:
                return null;
        }
    }

    public static function array(vl:Array<Value>):Array<Any> {
        var arr:Array<Any> = [];

        for (v in vl) {
            var a = any(v);
            if (a != null) {
                arr.push(a);
            }
        }

        return arr;
    }

    public static function percent(value:Value):Null<Float> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VDimension(v):
                switch (v) {
                    case Dimension.PERCENT(d):
                        return d;
                    case _:
                        return null;
                }
            case _:
                return null;
        }
    }

    public static function constant(value:Value, required:String):Bool {
        if (value == null) {
            return false;
        }

        switch (value) {
            case Value.VConstant(v):
                return v == required;
            case _:
                return false;
        }
    }

    public static function calcDimension(value:Value):Null<Float> {
        if (value == null) {
            return null;
        }

        switch (value) {
            case Value.VDimension(v):
                switch (v) {
                    case Dimension.PX(d):
                        return d;
                    case Dimension.VW(d):
                        return d / 100 * Screen.instance.width;
                    case Dimension.VH(d):
                        return d / 100 * Screen.instance.height;
                    case Dimension.REM(d):
                        return d * Toolkit.pixelsPerRem;
                    case _:
                        return null;
                }
            case Value.VNumber(v):
                return v;
            case Value.VCall(f, vl):
                return call(f, vl);
            case Value.VNone:
                return null;
            case _:
                return null;
        }
    }

    public static function calcEasing(value:Value):Null<EasingFunction> {
        switch (value) {
            case Value.VString(v), Value.VConstant(v):
                switch (v) {
                    case "linear":
                        return EasingFunction.LINEAR;
                    case "ease":
                        return EasingFunction.EASE;
                    case "ease-in":
                        return EasingFunction.EASE_IN;
                    case "ease-out":
                        return EasingFunction.EASE_OUT;
                    case "ease-in-out":
                        return EasingFunction.EASE_IN_OUT;
                    case _:
                        return null;
                }
            case _:
                return null;
        }
    }

    public static function call(f, vl:Array<Value>):Any {

        switch (f) {
            case "calc":
                #if hscript

                var parser = new hscript.Parser();
                var program = parser.parseString(string(vl[0]));

                var interp = new hscript.Interp();
                return interp.expr(program);

                #else

                return null;

                #end
            case "min":
                var minv:Float = Math.POSITIVE_INFINITY;
                for (val in vl) {
                    var num:Null<Float> = calcDimension(val);
                    if (num == null)
                        return null;
                    else if (num < minv)
                        minv = num;
                }
                return minv;
            case "max":
                var maxv:Float = Math.NEGATIVE_INFINITY;
                for (val in vl) {
                    var num:Null<Float> = calcDimension(val);
                    if (num == null)
                        return null;
                    else if (num > maxv)
                        maxv = num;
                }
                return maxv;
            case "clamp":
                var valNum:Null<Float> = calcDimension(vl[0]);
                var minNum:Null<Float> = calcDimension(vl[1]);
                var maxNum:Null<Float> = calcDimension(vl[2]);

                if (valNum == null || minNum == null || maxNum == null)
                    return null;
                else if (valNum < minNum)
                    return minNum;
                else if (valNum > maxNum)
                    return maxNum;
                else
                    return valNum;
            case "platform-color":
                return Platform.instance.getColor(ValueTools.string(vl[0]));
            case "theme-icon" | "theme-image":
                return ThemeManager.instance.image(ValueTools.string(vl[0]));
            case "rgb":
                return Color.fromComponents(ValueTools.int(vl[0]), ValueTools.int(vl[1]), ValueTools.int(vl[2]), 0).toInt();
            case "lookup":
                return Variant.toDynamic(StyleLookupMap.instance.get(ValueTools.string(vl[0])));
            case _:
                return null;
        }

        return null;
    }
}
package haxe.ui.styles;

import haxe.ui.constants.UnitTime;
import haxe.ui.core.Screen;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

using StringTools;

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
            if (s.indexOf("(") != -1) {
                var calls = extractCalls(s);
                if (calls.length == 1) {
                    var n = s.indexOf("(");
                    var f = s.substr(0, n);
                    var params = s.substr(n + 1, s.length - n - 2);
                    if (f == "calc") {
                        params = "'" + params + "'";
                    }
                    var vl = [];
                    for (p in paramsSplitter(params)) {
                        p = StringTools.trim(p);
                        vl.push(parse(p));
                    }
                    v = Value.VCall(f, vl);
                } else {
                    var vl = [];
                    for (a in calls) {
                        a = StringTools.trim(a);
                        vl.push(parse(a));
                    }
                    v = Value.VComposite(vl);
                }
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
        }

        return v;
    }

    private static function paramsSplitter(s:String) {
        var params = [];
        var counter = 0;
        var i = 0;
        var startParameter = 0;
        while (i < s.length) {
            var char = s.charAt(i);
            if (char == "," && counter == 0) {
                params.push(s.substring(startParameter, i));
                startParameter = i + 1;
            }
            if (char == "(") {
                counter--;
            } else if (char == ")") {
                counter++;
            }
            i++;
        }
        params.push(s.substring(startParameter, s.length));
        return params;
    }

    private static function extractCalls(s:String) {

        var calls = [];
        var counter = 0;

        var i = 0;
        var startCall = 0;
        var startParams = -1;
        while (i < s.length) {
            var char = s.charAt(i);
            if (char == "(") {
                if (startParams  == -1 ) startParams = i;
                counter--;
            } else if (char == ")") {
                counter++;
            }
            // If counter is 0, then it is at the end of function, as same number of left and right parenthesis
            if ((startParams != -1) && counter == 0) {
                var preParams = s.substring(startCall, startParams);

                // we check if there are "words" before the start of the function
                // 1px solid rgb(255, 0, 0) each word will be push in his own call
                var words = preParams.split(" ");
                for ( j in 0...words.length) {
                    var word = StringTools.trim(words[j]);
                    // If the last word we attach the content between the parenthesis as it's a function
                    if (j == words.length-1) {
                        var func_params = s.substring(startParams, i + 1); 
                        calls.push(word + func_params);
                    }
                    else {
                        if (word != "" ) calls.push(word);
                    }
                }
                
                startCall = i + 1;
                startParams = -1;
            }
            i++;
        }
        return calls;
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
            case Value.VDimension(_) | Value.VNumber(_) | Value.VString(_) | Value.VConstant(_):
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

    private static inline function parseColor(s:String):Value {
        return Value.VColor(Color.fromString(s));
    }

    private static inline function validColor(s:String):Bool {
        return Color.isValidColor(s);
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
            case Value.VCall(f, vl):
                return call(f, vl);
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
        if (!CssFunctions.hasCssFunction(f)) {
            trace("unknown css function: " + f);
            return null;
        }

        return CssFunctions.getCssFunction(f)(vl);
    }
}
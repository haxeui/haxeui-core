package haxe.ui.util;

#if haxeui_expose_all
@:expose
#end
class StringUtil {
    public static function uncapitalizeFirstLetter(s:String):String {
        s = s.substr(0, 1).toLowerCase() + s.substr(1, s.length);
        return s;
    }

    public static function capitalizeFirstLetter(s:String):String {
        s = s.substr(0, 1).toUpperCase() + s.substr(1, s.length);
        return s;
    }

    public static function capitalizeHyphens(s:String):String {
        return capitalizeDelim(s, "-");
    }

    public static function capitalizeDelim(s:String, d:String):String {
        var r:String = s;
        var n:Int = r.indexOf(d);
        while (n != -1) {
            var before:String = r.substr(0, n);
            var after:String = r.substr(n + 1, r.length);
            r = before + capitalizeFirstLetter(after);
            n = r.indexOf(d, n + 1);
        }
        return r;
    }

    public static function toDashes(s:String, toLower:Bool = true):String {
        var s = ~/([a-zA-Z])(?=[A-Z])/g.map(s, function(re:EReg):String {
            return '${re.matched(1)}-' ;
        });

        if (toLower == true) {
            s = s.toLowerCase();
        }

        return s;
    }

    public static function splitOnCapitals(s:String, toLower:Bool = true):Array<String> {
        return toDashes(s, toLower).split("-");
    }

    public static function replaceVars(s:String, params:Map<String, Dynamic>):String {
        if (params != null) {
            for (k in params.keys()) {
                s = StringTools.replace(s, "${" + k + "}", params.get(k));
            }
        }
        return s;
    }

    public static function rpad(s:String, count:Int, c:String = " "):String {
        for (i in 0...count) {
            s += c;
        }
        return s;
    }

    public static function padDecimal(v:Float, precision:Null<Int>):String {
        var s = Std.string(v);
        if (precision == null || precision <= 0) {
            return s;
        }

        var n = s.indexOf(".");
        if (n == -1) {
            n = s.length;
            s += ".";
        }

        var delta = precision - (s.length - n - 1);

        return rpad(s, delta, "0");
    }
    
    public static inline function countTokens(s:String, token:String):Int {
        if (s == null || s == "") {
            return 0;
        }
        return s.split(token).length - 1;
    }

    #if !macro // stringtools gets used in macros, but some functions rely on haxeui "bits" (like locales), lets wrap to avoid problems
    private static var humanReadableRegex = ~/\B(?=(\d{3})+(?!\d))/g;
    private static inline var THOUSAND:Int = 1000;
    private static inline var MILLION:Int = THOUSAND * THOUSAND;
    private static inline var BILLION:Int = MILLION * THOUSAND;

    public static function formatNumber(n:Float, precision:Int = 0, standardNotation:Bool = true, includeSpace:Bool = false):String {
        var s = Std.string(n);

        if (standardNotation) {
            var a = Math.abs(n);
            var i = n;
            var suffix = "";
            if (a >= 0 && a < THOUSAND) {
                suffix = "";
                i = n;
            } else if (a >= THOUSAND && a < MILLION) {
                suffix = "K";
                i = n / THOUSAND;
            } else if (a >= MILLION && a < BILLION) {
                suffix = "M";
                i = n / MILLION;
            } else {
                suffix = "B";
                i = n / BILLION;
            }

            if (suffix.length != 0 && includeSpace) {
                suffix = " " + suffix;
            }
            if (suffix.length != 0) {
                i = MathUtil.round(i, precision);
                s = Std.string(i);
                var p = s.indexOf(".");
                if (p == -1 && precision > 0) {
                    p = s.length;
                    s += ".";
                }
                s = StringTools.rpad(s, "0", p + precision + 1);
            }
            s += suffix;
        } else {
            s = humanReadableRegex.replace(s, haxe.ui.locale.Formats.thousandsSeparator);
        }

        return s;
    }
    #end
}
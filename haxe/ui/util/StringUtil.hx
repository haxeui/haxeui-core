package haxe.ui.util;

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

    public static function toDashes(s:String, toLower:Bool = true) {
        var s = ~/([a-zA-Z])(?=[A-Z])/g.map(s, function(re:EReg):String {
            return '${re.matched(1)}-' ;
        });
        
        if (toLower == true) {
            s = s.toLowerCase();
        }
        
        return s;
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
}
package;

class Util {
    public static function log(message:String) {
        Sys.println(message);
    }
    
    public static function mapContains(name:String, params:Array<String>, remove:Bool = false):Bool {
        var b = false;
        
        for (p in params) {
            if (p == name || p == '--${name}') {
                if (remove == true) {
                    params.remove(p);
                }
                b = true;
                break;
            }
        }
        
        return b;
    }
    
    public static function isBackend(s):Bool {
        return s == "html5"
               || s == "hxwidgets"
               || s == "openfl"
               || s == "nme"
               ;
    }
}
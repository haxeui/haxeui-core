package haxe.ui.layouts;

class LayoutFactory {
    private static var _map:Map<String, String> = new Map<String, String>();

    #if !macro
    public static function createFromName(name:String):Layout {
        var className = _map.get(name.toLowerCase());
        if (className == null) {
            trace("WARNING: layout '" + name + "' not found");
            return new DefaultLayout();
        }

        var cls = Type.resolveClass(className);
        if (cls == null) {
            trace("WARNING: layout '" + name + "' not found");
            return new DefaultLayout();
        }

        var instance = Type.createInstance(cls, []);
        return instance;
    }
    #end

    public static function register(name:String, className:String) {
        _map.set(name.toLowerCase(), className);
    }

    public static function lookupClass(name:String):String {
        return _map.get(name.toLowerCase());
    }
}
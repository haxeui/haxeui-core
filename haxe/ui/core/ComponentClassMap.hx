package haxe.ui.core;

class ComponentClassMap {
    private static var _instance:ComponentClassMap;
    public static var instance(get, never):ComponentClassMap;
    private static function get_instance():ComponentClassMap {
        if (_instance == null) {
            _instance = new ComponentClassMap();
        }
        return _instance;
    }

    public static function get(alias:String):String {
        alias = StringTools.replace(alias, "-", "").toLowerCase();
        return instance.getClassName(alias);
    }

    public static function register(alias:String, className:String) {
        instance.registerClassName(alias.toLowerCase(), className);
    }

    public static function list():Iterator<String> {
        return instance._map.keys();
    }

    public static function hasClass(className:String):Bool {
        return instance.hasClassName(className);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    // Instance
    ////////////////////////////////////////////////////////////////////////////////////////////

    private var _map:Map<String, String>;
    private function new() {
        _map = new Map<String, String>();
    }

    public function getClassName(alias:String):String {
        return _map.get(alias);
    }

    public function registerClassName(alias:String, className:String) {
        _map.set(alias, className);
    }

    public function hasClassName(className:String):Bool {
        for (k in _map.keys()) {
            if (_map.get(k) == className) {
                return true;
            }
        }
        return false;
    }
}
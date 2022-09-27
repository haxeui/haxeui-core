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
        instance.load();
        return instance._map.keys();
    }

    public static function clear() {
        instance._map = new Map<String, String>();
    }

    public static function hasClass(className:String):Bool {
        return instance.hasClassName(className);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Instance
    ////////////////////////////////////////////////////////////////////////////////////////////

    private var _map:Map<String, String> = null;
    private function new() {
        #if macro
        _map = new Map<String, String>();
        #end
    }

    public function getClassName(alias:String):String {
        load();
        alias = alias.toLowerCase();
        return _map.get(alias);
    }

    public function registerClassName(alias:String, className:String) {
        load();
        alias = alias.toLowerCase();
        if (_map.exists(alias) == false) {
            _map.set(alias, className);
        }
        save();
    }

    public function hasClassName(className:String):Bool {
        load();
        for (k in _map.keys()) {
            if (_map.get(k) == className) {
                return true;
            }
        }
        return false;
    }

    private function load() {
        #if !macro
        if (_map != null) {
            return;
        }

        var s = haxe.Resource.getString("haxeui_classmap");
        if (s == null) {
            return;
        }

        var unserializer = new Unserializer(s);
        _map = unserializer.unserialize();
        #end
    }

    private function save() {
        #if macro
        var serializer = new Serializer();
        serializer.serialize(_map);
        var s = serializer.toString();
        haxe.macro.Context.addResource("haxeui_classmap", haxe.io.Bytes.ofString(s));
        #end
    }
}
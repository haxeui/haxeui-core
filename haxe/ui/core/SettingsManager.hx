package haxe.ui.core;

class SettingsManager {
    private static var _instance:SettingsManager;
    public static var instance(get, null):SettingsManager;
    private static function get_instance():SettingsManager {
        if (_instance == null) {
            _instance = new SettingsManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private var _persister:ISettingsPersister = null;

    private function new() {
    }

    public function set<T>(name:String, value:Null<T>) {
        var serializer = new Serializer();
        serializer.serialize(value);
        var s = serializer.toString();
        getPersister().set(name, s);
    }

    public function get<T>(name:String, defaultValue:Null<T> = null):Null<T> {
        var s = getPersister().get(name);
        if (s == null) {
            return defaultValue;
        }
        var unserializer = new Unserializer(s);
        var v:Null<T> = cast unserializer.unserialize();
        return v;
    }

    private function getPersister():ISettingsPersister {
        if (_persister != null) {
            return _persister;
        }

        #if js 

        _persister = new haxe.ui.core.SettingsManager.LocalStorageSettingsPersister();

        #elseif sys

        _persister = new haxe.ui.core.SettingsManager.FileSettingsPersister();

        #else

        _persister = new haxe.ui.core.SettingsManager.NoOpSettingsPersister();

        #end

        return _persister;
    }
}

interface ISettingsPersister {
    public function set(name:String, value:String):Void;
    public function get(name:String):String;
}

#if js

class LocalStorageSettingsPersister implements ISettingsPersister {
    public function new() {
    }

    public function set(name:String, value:String):Void {
        var localStorage = js.Browser.window.localStorage;
        localStorage.setItem(name, value);
    }

    public function get(name:String):String {
        var localStorage = js.Browser.window.localStorage;
        return localStorage.getItem(name);
    }
}

#elseif sys

class FileSettingsPersister implements ISettingsPersister {
    public var filename:String = "settings.json";

    public function new() {
    }

    public function set(name:String, value:String):Void {
        var o = load();
        Reflect.setField(o, name, value);
        save(o);
    }

    public function get(name:String):String {
        var o = load();
        var v:String = Reflect.field(o, name);
        return v;
    }

    private function load():Dynamic {
        var o:Dynamic = null;
        if (sys.FileSystem.exists(filename)) {
            var jsonString = sys.io.File.getContent(filename);
            if (jsonString != null && jsonString.length > 0) {
                o = haxe.Json.parse(jsonString);
            }
        }
        if (o == null) {
            o = {};
        }
        return o;
    }

    private function save(o:Dynamic) {
        if (o == null) {
            o = {};
        }
        var jsonString = haxe.Json.stringify(o, null, "    ");
        sys.io.File.saveContent(filename, jsonString);
    }
}

#end

class NoOpSettingsPersister implements ISettingsPersister {
    public function new() {
    }

    public function set(name:String, value:String):Void {
    }

    public function get(name:String):String {
        return null;
    }
}
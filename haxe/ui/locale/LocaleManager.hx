package haxe.ui.locale;
import haxe.ui.ToolkitAssets;
import haxe.ui.binding.BindingManager;
import haxe.ui.parsers.locale.LocaleParser;

class LocaleManager {
    private static var _instance:LocaleManager;
    public static var instance(get, never):LocaleManager;
    private static function get_instance():LocaleManager {
        if (_instance == null) {
            _instance = new LocaleManager();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    
    private function new() {
    }
    
    private var _language:String = "en";
    public var language(get, set):String;
    private function get_language():String {
        return _language;
    }
    private function set_language(value:String):String {
        if (value == null) {
            return value;
        }
        if (_language == value) {
            return value;
        }

        if (getStrings(value) == null) {
            return value;
        }
        
        _language = value;
        BindingManager.instance.refreshAll();
        return value;
    }
    
    public function parseResource(localeId:String, resourceId:String) {
        var content = ToolkitAssets.instance.getText(resourceId);
        if (content != null) {
            var parts = resourceId.split(".");
            var extension = parts.pop();
            var filename = parts.join(".");
            var n = filename.lastIndexOf("/");
            if (n != -1) {
                filename = filename.substr(n + 1);
            }
            var parser = LocaleParser.get(extension);
            var map = parser.parse(content);
            addStrings(localeId, map, filename);
        }
    }
    
    private var _localeMap:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
    public function addStrings(localeId:String, map:Map<String, String>, filename:String = null) {
        var stringMap = _localeMap.get(localeId);
        if (stringMap == null) {
            stringMap = new Map<String, String>();
            _localeMap.set(localeId, stringMap);
        }
        for (k in map.keys()) {
            var v = map.get(k);
            if (filename != null && filename != localeId && StringTools.startsWith(k, filename) == false) {
                var altKey = filename + "." + k;
                stringMap.set(altKey, v);
            }
            stringMap.set(k, v);
        }
        
        localeId = StringTools.replace(localeId, "-", "_");
        var parts = localeId.split("_");
        if (parts.length > 1) {
            var parent = _localeMap.get(parts[0]);
            if (parent != null) {
                for (k in parent.keys()) {
                    if (stringMap.exists(k) == false) {
                        stringMap.set(k, parent.get(k));
                    }
                }
            }
        }
    }
    
    private function getStrings(localeId:String):Map<String, String> {
        var strings = _localeMap.get(localeId);
        if (strings != null) {
            return strings;
        }
        
        localeId = StringTools.replace(localeId, "-", "_");
        var parts = localeId.split("_");
        return _localeMap.get(parts[0]);
    }
    
    public function hasString(id:String):Bool {
        var strings = getStrings(language);
        if (strings == null) {
            return false;
        }
        return strings.exists(id);
    }
    
    public function lookupString(id:String, param0:Any = null, param1:Any = null, param2:Any = null, param3:Any = null) {
        var strings = getStrings(language);
        if (strings == null) {
            return id;
        }
        var value = strings.get(id);
        if (value == null) {
            return id;
        }
        
        if (param0 != null) value = StringTools.replace(value, "{0}", param0);
        if (param1 != null) value = StringTools.replace(value, "{1}", param1);
        if (param2 != null) value = StringTools.replace(value, "{2}", param2);
        if (param3 != null) value = StringTools.replace(value, "{3}", param3);
        
        return value;
    }
}
package haxe.ui.util;

import haxe.ui.Backend;

class Defines {
    private static var _map:Map<String, String> = null;
    public static function getAll():Map<String, String> {
        popuplate();
        return _map;
    }
    
    public static function set(name:String, value:String, overwrite:Bool = false) {
        popuplate();
        
        if (overwrite == false && _map.exists(name)) {
            return;
        }
        
        _map.set(name, value);
    }
    
    public static function popuplate() {
        if (_map != null) {
            return;
        }
        
        #if macro
        
        var defines = haxe.macro.Context.getDefines();
        _map = new Map<String, String>();
        
        for (k in defines.keys()) {
            var v = defines.get(k);
            _map.set(k, v);
            if (StringTools.startsWith(k, "haxeui_") || StringTools.startsWith(k, "haxeui-")) {
                k = k.substr(7);
                set(k, v);
            }
        }
        set("backend", Backend.id);
        if (Sys.systemName().toLowerCase().indexOf("windows") != -1) {
            set("windows", "1");
        } else if (Sys.systemName().toLowerCase().indexOf("linux") != -1) {
            set("linux", "1");
        } else if (Sys.systemName().toLowerCase().indexOf("mac") != -1) {
            set("mac", "1");
        }
        
        #else
        
        _map = new Map<String, String>();
        if (haxe.ui.core.Platform.instance.isWindows) {
            set("windows", "1");
        } else if (haxe.ui.core.Platform.instance.isLinux) {
            set("linux", "1");
        } else if (haxe.ui.core.Platform.instance.isMac) {
            set("mac", "1");
        }
        
        #end
    }
    
    public static function toObject():Dynamic {
        popuplate();
        var o = {};
        for (k in _map.keys()) {
            var v = _map.get(k);
            Reflect.setField(o, k, v);
        }
        return o;
    }
}
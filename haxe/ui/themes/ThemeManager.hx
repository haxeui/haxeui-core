package haxe.ui.themes;

import haxe.ds.ArraySort;
import haxe.ui.Toolkit;

class ThemeManager {
    private static var _instance:ThemeManager;
    public static var instance(get, null):ThemeManager;
    private static function get_instance():ThemeManager {
        if (_instance == null) {
            _instance = new ThemeManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private var _themes:Map<String, Theme>;

    public function new() {
        _themes = new Map<String, Theme>();
    }

    public function getTheme(themeName):Theme {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            theme = new Theme();
            _themes.set(themeName, theme);
        }
        return theme;
    }

    public function addStyleResource(themeName:String, resourceId:String, priority:Float = 0) {
        getTheme(themeName).styles.push({
           resourceId: resourceId,
           priority: priority
        });
    }

    public function addStyleText(themeName:String, styleText:String, priority:Float = 0) {
        getTheme(themeName).styles.push({
           resourceId: null,
           priority: priority,
           styleText: styleText
        });
    }

    public function applyTheme(themeName:String) {
        Toolkit.styleSheet.clear("default");
        var entries:Array<ThemeEntry> = [];
        var vars:Map<String, String> = new Map<String, String>();
        buildThemeEntries("global", entries, vars);
        buildThemeEntries(themeName, entries, vars);
        
        ArraySort.sort(entries, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });        
        
        for (e in entries) {
            if (e.resourceId != null) {
                applyResource(e.resourceId, vars);
            }
            if (e.styleText != null) {
                addStyleString(e.styleText, vars);
            }
        }
    }

    public function applyResource(resourceId:String, vars:Map<String, String> = null) {
        var style:String = Toolkit.assets.getText(resourceId);
        if (style != null) {
            addStyleString(style, vars);
        } else {
            #if debug
            trace("WARNING: could not find " + resourceId);
            #end
        }
    }
    
    public function addStyleString(style:String, vars:Map<String, String> = null) {
        if (vars != null && style.indexOf("${") != -1) {
            style = interpolate(style, vars);
        }
        Toolkit.styleSheet.parse(style);
    }
    
    private function interpolate(s:String, vars:Map<String, String>) {
        var copy:String = s;
        var n1:Int = copy.indexOf("${");
        while (n1 != -1) {
            var n2:Int = copy.indexOf("}", n1);
            var before:String = copy.substr(0, n1);
            var after:String = copy.substr(n2 + 1, copy.length);
            var varName:String = copy.substr(n1 + 2, n2 - n1 - 2);
            
            var result = vars.get(varName);
            if (result == null) {
                trace("WARNING: variable '" + varName + "' referenced in style but not found in theme vars");
                result = "";
            }
            copy = before + result + after;
            n1 = copy.indexOf("${");
        }
        return copy;
    }
    
    private function buildThemeEntries(themeName:String, arr:Array<ThemeEntry>, vars:Map<String, String>) {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            return;
        }
        if (theme.parent != null) {
            buildThemeEntries(theme.parent, arr, vars);
        }
        
        for (s in theme.styles) {
            arr.push(s);
        }
        
        if (theme.vars != null) {
            for (k in theme.vars.keys()) {
                var v = theme.vars.get(k);
                if (vars != null) {
                    vars.set(k, v);
                }
            }
        }
    }
}
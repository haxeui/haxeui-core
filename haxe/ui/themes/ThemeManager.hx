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

    public function applyTheme(themeName:String) {
        Toolkit.styleSheet.clear("default");
        var entries:Array<ThemeEntry> = [];
        buildThemeEntries("global", entries);
        buildThemeEntries(themeName, entries);
        
        ArraySort.sort(entries, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });        
        
        for (e in entries) {
            applyResource(e.resourceId);
        }
    }

    public function applyResource(resourceId:String) {
        var style:String = Toolkit.assets.getText(resourceId);
        if (style != null) {
            addStyleString(style);
        } else {
            #if debug
            trace("WARNING: could not find " + resourceId);
            #end
        }
    }
    
    public function addStyleString(style:String) {
        Toolkit.styleSheet.parse(style);
    }
    
    private function buildThemeEntries(themeName:String, arr:Array<ThemeEntry>) {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            return;
        }
        if (theme.parent != null) {
            buildThemeEntries(theme.parent, arr);
        }
        
        for (s in theme.styles) {
            arr.push(s);
        }
    }
}
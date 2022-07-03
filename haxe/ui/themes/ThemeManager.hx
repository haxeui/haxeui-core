package haxe.ui.themes;

import haxe.ds.ArraySort;
import haxe.ui.Toolkit;
import haxe.ui.events.ThemeEvent;
import haxe.ui.util.EventMap;

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
    private var _themeImages:Map<String, ThemeImageEntry>;
    private var _eventMap:EventMap = null;

    public function new() {
        _themes = new Map<String, Theme>();
    }

    public function registerEvent<T:ThemeEvent>(type:String, listener:T->Void, priority:Int = 0) {
        if (_eventMap == null) {
            _eventMap = new EventMap();
        }
        
        _eventMap.add(type, listener);
    }
    
    public function unregisterEvent<T:ThemeEvent>(type:String, listener:T->Void) {
        if (_eventMap == null) {
            return;
        }
        
        _eventMap.remove(type, listener);
    }
    
    private function dispatch(event:ThemeEvent) {
        if (_eventMap == null) {
            return;
        }
        
        _eventMap.invoke(event.type, new ThemeEvent(ThemeEvent.THEME_CHANGED));
    }
    
    public function getTheme(themeName):Theme {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            theme = new Theme();
            _themes.set(themeName, theme);
        }
        return theme;
    }

    public function addStyleResource(themeName:String, resourceId:String, priority:Float = 0, styleData:String = null) {
        getTheme(themeName).styles.push({
            resourceId: resourceId,
            priority: priority,
            styleData: styleData
        });
    }

    public function setThemeVar(themeName:String, varName:String, varValue:String) {
        var theme = getTheme(themeName);
        if (theme == null) {
            return;
        }
        theme.vars.set(varName, varValue);
    }
    
    public function setCurrentThemeVar(varName:String, varValue:String) {
        setThemeVar(Toolkit.theme, varName, varValue);
    }
    
    public function addImageResource(themeName:String, id:String, resourceId:String, priority:Float = 0) {
        getTheme(themeName).images.push({
            id: id,
            resourceId: resourceId,
            priority: priority
        });
    }

    private var currentThemeVars:Map<String, String> = new Map<String, String>();
    
    public function applyTheme(themeName:String) {
        Toolkit.styleSheet.clear("default");

        // vars
        var finalVars:Map<String, String> = new Map<String, String>();
        buildThemeVars("global", finalVars);
        buildThemeVars(themeName, finalVars);
        currentThemeVars = new Map<String, String>();
        for (k in finalVars.keys()) {
            currentThemeVars.set(k, finalVars.get(k));
        }

        
        // stylesheet entries
        var entries:Array<ThemeEntry> = [];
        buildThemeEntries("global", entries);
        buildThemeEntries(themeName, entries);

        ArraySort.sort(entries, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });

        for (e in entries) {
            applyResource(e.resourceId, e.styleData);
        }

        // images
        var images:Array<ThemeImageEntry> = [];
        buildThemeImages("global", images);
        buildThemeImages(themeName, images);
        ArraySort.sort(images, function(a, b):Int {
            if (a.priority < b.priority) return -1;
            else if (a.priority > b.priority) return 1;
            return 0;
        });

        for (i in images) {
            if (_themeImages == null) {
                _themeImages = new Map<String, ThemeImageEntry>();
            }
            _themeImages.set(i.id, i);
        }
        
        dispatch(new ThemeEvent(ThemeEvent.THEME_CHANGED));
    }

    public function applyResource(resourceId:String, styleData:String = null) {
        var style:String = "";
        if (resourceId != null) {
            style = Toolkit.assets.getText(resourceId);
        }
        if (styleData != null) {
            if (style == null) {
                style = "";
            }
            style += "\n" + styleData;
        }
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

    private function buildThemeVars(themeName:String, vars:Map<String, String>) {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            return;
        }
        if (theme.parent != null) {
            buildThemeVars(theme.parent, vars);
        }
        
        for (k in theme.vars.keys()) {
            var v = theme.vars.get(k);
            vars.set(k, v);
        }
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

    private function buildThemeImages(themeName:String, arr:Array<ThemeImageEntry>) {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            return;
        }
        if (theme.parent != null) {
            buildThemeImages(theme.parent, arr);
        }

        for (s in theme.images) {
            arr.push(s);
        }
    }

    //****************************************************************************************************
    // Helpers
    //****************************************************************************************************
    public function image(id:String):String {
        var image = _themeImages.get(id);
        if (image == null) {
            return null;
        }
        return image.resourceId;
    }

    public function icon(id:String):String { // semantics
        return image(id);
    }
}
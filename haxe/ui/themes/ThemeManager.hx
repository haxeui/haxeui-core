package haxe.ui.themes;

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

    public function addStyleResource(themeName:String, resourceId:String) {
        getTheme(themeName).styles.push(resourceId);
    }

    public function applyTheme(themeName:String) {
        applyThemeStyles("global");
        applyThemeStyles(themeName);
    }

    public function applyThemeStyles(themeName:String) {
        var theme:Theme = _themes.get(themeName);
        if (theme == null) {
            return;
        }
        if (theme.parent != null) {
            applyThemeStyles(theme.parent);
        }

        var styles = theme.styles;
        styles.reverse();
        for (s in styles) {
            var css:String = Toolkit.assets.getText(s);
            if (css != null) {
                Toolkit.styleSheet.addRules(css);
            } else {
                #if debug
                trace("WARNING: could not find " + s);
                #end
            }
        }
    }
}
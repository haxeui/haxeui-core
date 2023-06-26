package haxe.ui.styles;

import haxe.ui.filters.Filter;

class CssFilters {
    private static var _cssFilters:Map<String, Void->Filter> = new Map<String, Void->Filter>();

    public static function registerCssFilter(name:String, ctor:Void->Filter) {
        _cssFilters.set(name, ctor);
    }

    public static inline function hasCssFilter(name:String):Bool {
        return _cssFilters.exists(name);
    }

    public static inline function getCssFilter(name:String):Void->Filter {
        return _cssFilters.get(name);
    }
    
}
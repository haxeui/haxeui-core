package haxe.ui.themes;

class Theme {
    public static inline var DEFAULT:String = "default";
    public static inline var DARK:String = "dark";
    
    public var parent:String;
    public var styles:Array<ThemeEntry>;
    public var images:Array<ThemeImageEntry>;
    public var vars:Map<String, String>;

    public function new() {
        styles = [];
        images = [];
        vars = new Map<String, String>();
    }
}
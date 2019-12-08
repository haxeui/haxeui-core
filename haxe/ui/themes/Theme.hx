package haxe.ui.themes;

class Theme {
    public var parent:String;
    public var styles:Array<ThemeEntry>;
    public var vars:Map<String, String>;

    public function new() {
        styles = [];
    }
}
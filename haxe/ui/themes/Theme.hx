package haxe.ui.themes;

class Theme {
    public var parent:String;
    public var styles:Array<ThemeEntry>;

    public function new() {
        styles = [];
    }
}
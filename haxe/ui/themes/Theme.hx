package haxe.ui.themes;

class Theme {
    public var parent:String;
    public var styles:Array<ThemeEntry>;
    public var images:Array<ThemeImageEntry>;

    public function new() {
        styles = [];
        images = [];
    }
}
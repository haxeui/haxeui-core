package haxe.ui.parsers.ui;

class ComponentStyleInfo {
    public var scope:String = "global";
    public var style:String = null;

    public function new(style:String, scope:String = "global") {
        this.style = style;
        this.scope = scope;
    }
}
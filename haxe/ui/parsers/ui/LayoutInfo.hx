package haxe.ui.parsers.ui;

class LayoutInfo {
    public var type:String;

    public var properties:Map<String, String>;

    public function new() {
        properties = new Map<String, String>();
    }
}

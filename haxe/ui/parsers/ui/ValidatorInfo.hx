package haxe.ui.parsers.ui;

class ValidatorInfo {
    public var type:String;
    public var properties:Map<String, Any>;

    public function new() {
        properties = new Map<String, Any>();
    }
}
package haxe.ui.parsers.modules;

class JSONParser extends ObjectParser {
    public function new() {
        super();
    }

    public override function parse(data:String):Module {
        return fromObject(Json.parse(data));
    }
}
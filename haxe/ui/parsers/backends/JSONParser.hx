package haxe.ui.parsers.backends;
import haxe.Json;

class JSONParser extends ObjectParser {
	public function new() {
		super();
	}
	
	public override function parse(data:String):Backend {
		return fromObject(Json.parse(data));
	}
}
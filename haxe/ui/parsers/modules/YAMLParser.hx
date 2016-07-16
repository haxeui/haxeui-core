package haxe.ui.parsers.modules;

#if yaml
import yaml.Parser;
import yaml.Yaml;

class YAMLParser extends ObjectParser {
    public function new() {
        super();
    }

    public override function parse(data:String):Module {
        return fromObject(Yaml.parse(data, Parser.options().useObjects()));
    }
}
#end
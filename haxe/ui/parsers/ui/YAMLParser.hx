package haxe.ui.parsers.ui;

#if yaml
import haxe.ui.parsers.ui.resolvers.ResourceResolver;
import yaml.Parser;
import yaml.Yaml;

class YAMLParser extends ObjectParser {
    public function new() {
        super();
    }

    public override function parse(data:String, resourceResolver:ResourceResolver = null):ComponentInfo {
        _resourceResolver = resourceResolver;
        return fromObject(Yaml.parse(data, Parser.options().useObjects()), resourceResolver);
    }
}
#end
package haxe.ui.parsers.config;

import haxe.ui.util.GenericConfig;

class XMLParser extends ConfigParser {
    public function new() {
        super();
    }

    public override function parse(data:String):GenericConfig {
        var config:GenericConfig = new GenericConfig();

        var xml:Xml = Xml.parse(data).firstElement();
        for (el in xml.elements()) {
            parseAddionalConfig(el, config);
        }

        return config;
    }

    private function parseAddionalConfig(node:Xml, parent:GenericConfig) {
        var group = parent.addSection(node.nodeName);
        for (attr in node.attributes()) {
            group.values.set(attr, node.get(attr));
        }
        for (el in node.elements()) {
            parseAddionalConfig(el, group);
        }
    }
}
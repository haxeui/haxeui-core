package haxe.ui.parsers.config;

import haxe.ui.util.GenericConfig;

class XMLParser extends ConfigParser {
    public function new() {
        super();
    }

    public override function parse(data:String, defines:Map<String, String>):GenericConfig {
        var config:GenericConfig = new GenericConfig();

        var xml:Xml = Xml.parse(data).firstElement();
        for (el in xml.elements()) {
            parseAddionalConfig(el, config, defines);
        }

        return config;
    }

    private function parseAddionalConfig(node:Xml, parent:GenericConfig, defines:Map<String, String>) {
        if (node.get("if") != null) {
            var condition = "haxeui_" + node.get("if");
            if (defines.exists(condition) == false) {
                return;
            }
        }
        
        var group = parent.addSection(node.nodeName);
        for (attr in node.attributes()) {
            group.values.set(attr, node.get(attr));
        }
        for (el in node.elements()) {
            parseAddionalConfig(el, group, defines);
        }
    }
}
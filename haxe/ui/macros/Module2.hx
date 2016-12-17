package haxe.ui.macros;

class Module2 {
    public var id(default, default):String;
    public var resourceEntries(default, default):Array<ModuleResourceEntry>;
    public var themeEntries(default, default):Map<String, ModuleThemeEntry>;

    public function new() {
        resourceEntries = [];
        themeEntries = new Map<String, ModuleThemeEntry>();
    }

    public function fromXML(xml:Xml) {
        id = xml.get("id");

        for (el in xml.elements()) {
            var nodeName:String = el.nodeName;

            if (nodeName == "resources") {
                for (resourceNode in el.elementsNamed("resource")) {
                    var resourceEntry:ModuleResourceEntry = new ModuleResourceEntry();
                    resourceEntry.path = resourceNode.get("path");
                    resourceEntry.prefix = resourceNode.get("prefix");
                    resourceEntries.push(resourceEntry);
                }
            } else if (nodeName == "themes") {
                for (themeNode in el.elements()) {
                    var theme:ModuleThemeEntry = new ModuleThemeEntry();
                    theme.name = themeNode.nodeName;
                    theme.parent = themeNode.get("parent");
                    for (styleNodes in themeNode.elementsNamed("style")) {
                        var styleResource:String = styleNodes.get("resource");
                        theme.styles.push(styleResource);
                    }
                    themeEntries.set(theme.name, theme);
                }
            }
        }
    }
}

class ModuleResourceEntry {
    public function new() {
    }

    public var path(default, default):String;
    public var prefix(default, default):String;
}

class ModuleThemeEntry {
    public function new() {
        styles = [];
    }

    public var name(default, default):String;
    public var parent(default, default):String;
    public var styles(default, default):Array<String>;
}
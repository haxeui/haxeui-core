package haxe.ui.parsers.modules;

import haxe.ui.parsers.modules.Module.ModuleThemeImageEntry;
import haxe.ui.parsers.modules.Module.ModuleThemeStyleEntry;

class XMLParser extends ModuleParser {
    public function new() {
        super();
    }

    public override function parse(data:String, defines:Map<String, String>, context:String = null):Module {
        var module:Module = new Module();

        var xml:Xml = Xml.parse(data).firstElement();
        module.id = xml.get("id");
        if (xml.get("priority") != null) {
            module.priority = Std.parseInt(xml.get("priority"));
        }
        module.preloadList = xml.get("preload");

        for (el in xml.elements()) {
            var nodeName:String = el.nodeName;

            if (nodeName == "resources" && checkCondition(el, defines) == true) {
                for (resourceNode in el.elementsNamed("resource")) {
                    if (checkCondition(resourceNode, defines) == false) {
                        continue;
                    }
                    var resourceEntry:Module.ModuleResourceEntry = new Module.ModuleResourceEntry();
                    resourceEntry.path = resourceNode.get("path");
                    resourceEntry.prefix = resourceNode.get("prefix");
                    module.resourceEntries.push(resourceEntry);
                }
            } else if (nodeName == "components" && checkCondition(el, defines) == true) {
                for (classNode in el.elementsNamed("class")) {
                    if (checkCondition(classNode, defines) == false) {
                        continue;
                    }
                    var classEntry:Module.ModuleComponentEntry = new Module.ModuleComponentEntry();
                    classEntry.classPackage = classNode.get("package");
                    classEntry.className = classNode.get("name");
                    classEntry.classFolder = classNode.get("folder");
                    classEntry.classFile = classNode.get("file");
                    classEntry.classAlias = classNode.get("alias");
                    module.componentEntries.push(classEntry);
                }
                for (classNode in el.elementsNamed("component")) {
                    if (checkCondition(classNode, defines) == false) {
                        continue;
                    }
                    var classEntry:Module.ModuleComponentEntry = new Module.ModuleComponentEntry();
                    classEntry.classPackage = classNode.get("package");
                    classEntry.className = classNode.get("class");
                    classEntry.classFolder = classNode.get("folder");
                    classEntry.classFile = classNode.get("file");
                    classEntry.classAlias = classNode.get("alias");
                    module.componentEntries.push(classEntry);
                }
            } else if (nodeName == "layouts" && checkCondition(el, defines) == true) {
                for (classNode in el.elementsNamed("class")) {
                    if (checkCondition(classNode, defines) == false) {
                        continue;
                    }
                    var classEntry:Module.ModuleLayoutEntry = new Module.ModuleLayoutEntry();
                    classEntry.classPackage = classNode.get("package");
                    classEntry.className = classNode.get("name");
                    classEntry.classAlias = classNode.get("alias");
                    module.layoutEntries.push(classEntry);
                }
            } else if (nodeName == "scriptlets" && checkCondition(el, defines) == true) {
                for (classNode in el.elementsNamed("import")) {
                    if (checkCondition(classNode, defines) == false) {
                        continue;
                    }

                    var scriptletEntry:Module.ModuleScriptletEntry = new Module.ModuleScriptletEntry();
                    scriptletEntry.classPackage = classNode.get("package");
                    scriptletEntry.className = classNode.get("class");
                    scriptletEntry.classAlias = classNode.get("alias");
                    scriptletEntry.keep = (classNode.get("keep") == "true");
                    scriptletEntry.staticClass = (classNode.get("static") == "true");
                    module.scriptletEntries.push(scriptletEntry);
                }
            } else if (nodeName == "themes" && checkCondition(el, defines) == true) {
                for (themeNode in el.elements()) {
                    if (checkCondition(themeNode, defines) == false) {
                        continue;
                    }

                    var theme:Module.ModuleThemeEntry = new Module.ModuleThemeEntry();
                    theme.name = themeNode.nodeName;
                    theme.parent = themeNode.get("parent");

                    // style entries
                    var lastPriority:Null<Float> = null;
                    for (styleNodes in themeNode.elementsNamed("style")) {
                        if (checkCondition(styleNodes, defines) == false) {
                            continue;
                        }
                        var styleEntry:ModuleThemeStyleEntry = new ModuleThemeStyleEntry();
                        styleEntry.resource = styleNodes.get("resource");
                        if (styleNodes.get("priority") != null) {
                            styleEntry.priority = Std.parseFloat(styleNodes.get("priority"));
                            lastPriority = styleEntry.priority;
                        } else if (lastPriority != null) {
                            lastPriority += 0.01;
                            styleEntry.priority = lastPriority;
                        } else if (context.indexOf("haxe/ui/backend/") != -1) { // lets auto the priority based on if we _think_ this is a backed - not fool proof, but a good start (means it doesnt HAVE to be in module.xml)
                            if (theme.name == "global") { // special case
                                styleEntry.priority = -2;
                                lastPriority = -2;
                            } else {
                                styleEntry.priority = -1;
                                lastPriority = -1;
                            }
                        }
                        theme.styles.push(styleEntry);
                    }

                    // image entries
                    var lastPriority:Null<Float> = null;
                    for (imageNodes in themeNode.elements()) {
                        if (checkCondition(imageNodes, defines) == false) {
                            continue;
                        }

                        if (imageNodes.nodeName != "image" && imageNodes.nodeName != "icon") {
                            continue;
                        }

                        var imageEntry:ModuleThemeImageEntry = new ModuleThemeImageEntry();
                        imageEntry.id = imageNodes.get("id");
                        imageEntry.resource = imageNodes.get("resource");
                        if (imageNodes.get("priority") != null) {
                            imageEntry.priority = Std.parseFloat(imageNodes.get("priority"));
                            lastPriority = imageEntry.priority;
                        } else if (lastPriority != null) {
                            lastPriority += 0.01;
                            imageEntry.priority = lastPriority;
                        } else if (context.indexOf("haxe/ui/backend/") != -1) { // lets auto the priority based on if we _think_ this is a backed - not fool proof, but a good start (means it doesnt HAVE to be in module.xml)
                            if (theme.name == "global") { // special case
                                imageEntry.priority = -2;
                                lastPriority = -2;
                            } else {
                                imageEntry.priority = -1;
                                lastPriority = -1;
                            }
                        }
                        theme.images.push(imageEntry);
                    }

                    module.themeEntries.set(theme.name, theme);
                }
            } else if (nodeName == "plugins" && checkCondition(el, defines) == true) {
                for (pluginNode in el.elementsNamed("plugin")) {
                    if (checkCondition(pluginNode, defines) == false) {
                        continue;
                    }
                    var plugin:Module.ModulePluginEntry = new Module.ModulePluginEntry();
                    for (attr in pluginNode.attributes()) {
                        var value = pluginNode.get(attr);
                        switch (attr) {
                            case "type":
                                plugin.type = value;
                            case "class":
                                plugin.className = value;
                            default:
                                plugin.config.set(attr, value);
                        }
                    }
                    module.plugins.push(plugin);
                }
            } else if (nodeName == "properties" && checkCondition(el, defines) == true) {
                for (propertyNode in el.elementsNamed("property")) {
                    if (checkCondition(propertyNode, defines) == false) {
                        continue;
                    }
                    var property:Module.ModulePropertyEntry = new Module.ModulePropertyEntry();
                    property.name = propertyNode.get("name");
                    property.value = propertyNode.get("value");
                    module.properties.push(property);
                }
            } else if (nodeName == "preload" && checkCondition(el, defines) == true) {
                for (propertyNode in el.elements()) {
                    if (checkCondition(propertyNode, defines) == false) {
                        continue;
                    }
                    var entry:Module.ModulePreloadEntry = new Module.ModulePreloadEntry();
                    entry.type = propertyNode.nodeName;
                    entry.id = propertyNode.get("id");
                    module.preload.push(entry);
                }
            } else if (nodeName == "locales" && checkCondition(el, defines) == true) {
                for (propertyNode in el.elements()) {
                    if (checkCondition(propertyNode, defines) == false) {
                        continue;
                    }
                    var entry:Module.ModuleLocaleEntry = new Module.ModuleLocaleEntry();
                    entry.id = propertyNode.get("id");
                    if (propertyNode.get("resource") != null) {
                        entry.resources.push(propertyNode.get("resource"));
                    }
                    for (resourceNode in propertyNode.elementsNamed("resource")) {
                        if (resourceNode.get("path") != null) {
                            entry.resources.push(resourceNode.get("path"));
                        }
                    }
                    module.locales.push(entry);
                }
            }
        }

        return module;
    }

    private function checkCondition(node:Xml, defines:Map<String, String>):Bool {
        if (node.get("if") != null) {
            var condition = node.get("if");
            return defines.exists(condition);
        } else if (node.get("unless") != null) {
            var condition = node.get("unless");
            return !defines.exists(condition);
        }

        return true;
    }
}
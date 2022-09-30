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
        module.preloader = xml.get("preloader");
        if (xml.get("priority") != null) {
            module.priority = Std.parseInt(xml.get("priority"));
        }
        module.preloadList = xml.get("preload");

        for (el in xml.elements()) {
            var nodeName:String = el.nodeName;

            if (nodeName == "resources" && checkCondition(el, defines) == true) {
                // parse global exclusions
                if (el.get("exclude") != null) {
                    Module.ModuleResourceEntry.globalExclusions.push(el.get("exclude"));
                }
                for (excludeNode in el.elementsNamed("exclude")) {
                    if (checkCondition(excludeNode, defines) == false) {
                        continue;
                    }
                    if (excludeNode.get("pattern") != null) {
                        Module.ModuleResourceEntry.globalExclusions.push(excludeNode.get("pattern"));
                    }
                }
                
                // parse blobal inclusions
                if (el.get("include") != null) {
                    Module.ModuleResourceEntry.globalInclusions.push(el.get("include"));
                }
                for (includeNode in el.elementsNamed("include")) {
                    if (checkCondition(includeNode, defines) == false) {
                        continue;
                    }
                    if (includeNode.get("pattern") != null) {
                        Module.ModuleResourceEntry.globalInclusions.push(includeNode.get("pattern"));
                    }
                }
                
                for (resourceNode in el.elementsNamed("resource")) {
                    if (checkCondition(resourceNode, defines) == false) {
                        continue;
                    }
                    var resourceEntry:Module.ModuleResourceEntry = new Module.ModuleResourceEntry();
                    resourceEntry.path = resourceNode.get("path");
                    resourceEntry.prefix = resourceNode.get("prefix");
                    
                    // parse exclusions
                    if (resourceNode.get("exclude") != null) {
                        resourceEntry.exclusions.push(resourceNode.get("exclude"));
                    }
                    for (excludeNode in resourceNode.elementsNamed("exclude")) {
                        if (checkCondition(excludeNode, defines) == false) {
                            continue;
                        }
                        if (excludeNode.get("pattern") != null) {
                            resourceEntry.exclusions.push(excludeNode.get("pattern"));
                        }
                    }
                    
                    // parse inclusions
                    if (resourceNode.get("include") != null) {
                        resourceEntry.inclusions.push(resourceNode.get("include"));
                    }
                    for (includeNode in resourceNode.elementsNamed("include")) {
                        if (checkCondition(includeNode, defines) == false) {
                            continue;
                        }
                        if (includeNode.get("pattern") != null) {
                            resourceEntry.inclusions.push(includeNode.get("pattern"));
                        }
                    }
                    
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
                    if (classNode.get("loadAll") != null) {
                        classEntry.loadAll = (classNode.get("loadAll") == "true");
                    }
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
                    if (classNode.get("loadAll") != null) {
                        classEntry.loadAll = (classNode.get("loadAll") == "true");
                    }
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
                    module.layoutEntries.push(classEntry);
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
                        if (styleNodes.firstChild() != null) {
                            styleEntry.styleData = styleNodes.firstChild().nodeValue;
                        }
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
                    
                    for (varNode in themeNode.elementsNamed("var")) {
                        if (checkCondition(varNode, defines) == false) {
                            continue;
                        }
                        theme.vars.set(varNode.get("name"), varNode.get("value"));
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
            } else if (nodeName == "actions" && checkCondition(el, defines) == true) {
                for (sourceNode in el.elementsNamed("source")) {
                    if (checkCondition(sourceNode, defines) == false) {
                        continue;
                    }
                    
                    var entry:Module.ModuleActionInputSourceEntry = new Module.ModuleActionInputSourceEntry();
                    entry.className = sourceNode.get("class");
                    module.actionInputSources.push(entry);
                }
            } else if (nodeName == "namespaces" && checkCondition(el, defines) == true) {
                for (namespaceNode in el.elementsNamed("namespace")) {
                    if (checkCondition(namespaceNode, defines) == false) {
                        continue;
                    }

                    var namespacePrefix = namespaceNode.get("prefix");
                    var namespaceURI = namespaceNode.get("uri");
                    if (namespacePrefix != null && namespacePrefix.length > 0 && namespaceURI != null && namespaceURI.length > 0) {
                        module.namespaces.set(namespacePrefix, namespaceURI);
                    }
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
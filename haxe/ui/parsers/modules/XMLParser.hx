package haxe.ui.parsers.modules;
import haxe.ui.parsers.modules.Module.ModuleThemeStyleEntry;

class XMLParser extends ModuleParser {
    public function new() {
        super();
    }

    public override function parse(data:String, defines:Map<String, String>):Module {
        var module:Module = new Module();

        var xml:Xml = Xml.parse(data).firstElement();
        module.id = xml.get("id");

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
                    classEntry.classAlias = classNode.get("alias");
                    module.componentEntries.push(classEntry);
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
                    for (styleNodes in themeNode.elementsNamed("style")) {
                        if (checkCondition(styleNodes, defines) == false) {
                            continue;
                        }
                        var styleEntry:ModuleThemeStyleEntry = new ModuleThemeStyleEntry();
                        styleEntry.resource = styleNodes.get("resource");
                        theme.styles.push(styleEntry);
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
            } else if (nodeName == "animations" && checkCondition(el, defines) == true) {
                for (animationNode in el.elementsNamed("animation")) {
                    if (checkCondition(animationNode, defines) == false) {
                        continue;
                    }
                    var animation:Module.ModuleAnimationEntry = new Module.ModuleAnimationEntry();
                    animation.id = animationNode.get("id");
                    animation.ease = animationNode.get("ease");

                    for (keyFrameNode in animationNode.elementsNamed("keyframe")) {
                        var keyFrame:Module.ModuleAnimationKeyFrameEntry = new Module.ModuleAnimationKeyFrameEntry();
                        if (keyFrameNode.get("time") != null) {
                            keyFrame.time = Std.parseInt(keyFrameNode.get("time"));
                        }

                        for (componentRefNode in keyFrameNode.elements()) {
                            var componentRef:Module.ModuleAnimationComponentRefEntry = new Module.ModuleAnimationComponentRefEntry();
                            componentRef.id = componentRefNode.nodeName;
                            for (attrName in componentRefNode.attributes()) {
                                var attrValue = componentRefNode.get(attrName);
                                if (StringTools.startsWith(attrValue, "{") && StringTools.endsWith(attrValue, "}")) {
                                    attrValue = attrValue.substring(1, attrValue.length - 1);
                                    componentRef.vars.set(attrName, attrValue);
                                } else {
                                    componentRef.properties.set(attrName, Std.parseFloat(attrValue));
                                }
                            }

                            keyFrame.componentRefs.set(componentRef.id, componentRef);
                        }

                        animation.keyFrames.push(keyFrame);
                    }

                    module.animations.push(animation);
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
            }
        }

        return module;
    }

    private function checkCondition(node:Xml, defines:Map<String, String>):Bool {
        if (node.get("if") != null) {
            var condition = "haxeui_" + node.get("if");
            return defines.exists(condition);
        }
        
        return true;
    }
}
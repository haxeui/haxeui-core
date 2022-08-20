package haxe.ui.parsers.ui;

import haxe.ui.parsers.ui.resolvers.ResourceResolver;

class XMLParser extends ComponentParser {
    public function new() {
        super();
    }

    public override function parse(data:String, resourceResolver:ResourceResolver = null, fileName:String = null):ComponentInfo {
        _resourceResolver = resourceResolver;

        var component:ComponentInfo = new ComponentInfo();

        #if (haxe_ver >= 4.1)
        
        try {
            data = preprocess(data);
            var xml:Xml = Xml.parse(data).firstElement();
            parseComponent(component, xml, resourceResolver);
        } catch (e:haxe.ui.parsers.ui.ComponentParser.ComponentParserException) {
            throw new haxe.ui.parsers.ui.ComponentParser.ComponentParserException('while parsing "${e.fileName}": ${e.original.message}', e.fileName, e.original, e);
        } catch (e:Exception) {
            throw new haxe.ui.parsers.ui.ComponentParser.ComponentParserException('while parsing "${fileName}": ${e.message}', fileName, e, e);
        }
        
        #else
        
        var xml:Xml = Xml.parse(data).firstElement();
        parseComponent(component, xml, resourceResolver);
            
        #end

        return component;
    }

    private static function preprocess(data:String):String {
        data = StringTools.replace(data, "<script>", "<script><![CDATA[");
        data = StringTools.replace(data, "</script>", "]]></script>");
        return data;
    }
    
    private static function parseComponent(component:ComponentInfo, xml:Xml, resourceResolver:ResourceResolver):Bool {
        var isComponent:Bool = false;
        var nodeName = xml.nodeName;
        if (nodeName == "import") {
            parseImportNode(component.parent, xml, resourceResolver);
        } else if (nodeName == "script") {
            parseScriptNode(component, xml, resourceResolver);
        } else if (nodeName == "style") {
            parseStyleNode(component, xml, resourceResolver);
        } else if (nodeName == "data") {
            if (xml.firstElement() != null) {
                component.parent.data = StringTools.trim(xml.toString());
            } else if (StringTools.startsWith(StringTools.trim(xml.firstChild().nodeValue), "[")) {
                component.parent.data = StringTools.trim(xml.firstChild().nodeValue);
            }
        } else if (nodeName == "layout") {
            parseLayoutNode(component.parent, xml);
        } else {
            parseDetails(component, xml);
            parseAttributes(component, xml);

            for (childXml in xml.elements()) {
                var child:ComponentInfo = new ComponentInfo();
                child.parent = component;
                if (parseComponent(child, childXml, resourceResolver) == true) {
                    component.children.push(child);
                }
            }

            if (component.type == "itemrenderer" && component.parent != null && component.parent.type.toLowerCase() == "listview") {
                component.parent.properties.set("native", "false");
            }

            component.validate();
            isComponent = true;
        }
        
        return isComponent;
    }

    private static function parseImportNode(component:ComponentInfo, xml:Xml, resourceResolver:ResourceResolver) {
        if (xml.get("source") != null || xml.get("resource") != null) {
            var source:String = xml.get("source");
            if (source == null) {
                source = xml.get("resource");
            }
            var omitRoot = xml.get("omitRoot") == "true";
            var sourceData:String = resourceResolver.getResourceData(source);
            if (sourceData != null) {
                var extension:String = resourceResolver.extension(source);
                var c:ComponentInfo = ComponentParser.get(extension).parse(sourceData, resourceResolver, source);

                component.findRootComponent().styles = component.findRootComponent().styles.concat(c.styles);
                c.styles = [];

                component.findRootComponent().scriptlets = component.findRootComponent().scriptlets.concat(c.scriptlets);
                c.scriptlets = [];

                if (omitRoot == false) {
                    c.parent = component;
                    component.children.push(c);
                } else {
                    for (child in c.children) {
                        child.parent = component;
                        component.children.push(child);
                    }
                }
            }
        }
    }

    private static function parseScriptNode(component:ComponentInfo, xml:Xml, resourceResolver:ResourceResolver) {
        var scriptText = null;
        if (xml.firstChild() != null) {
            scriptText = xml.firstChild().nodeValue;
        }

        if (xml.get("source") != null) {
            var source:String = xml.get("source");
            var sourceData:String = resourceResolver.getResourceData(source);
            if (sourceData != null) {
                if (scriptText == null) {
                    scriptText = "";
                }
                scriptText += "\n" + sourceData;
            }
        }

        if (scriptText != null) {
            var scope:String = "global";
            if (scope == "global") {
                component.findRootComponent().scriptlets.push(scriptText);
            }
        }
    }

    private static function parseStyleNode(component:ComponentInfo, xml:Xml, resourceResolver:ResourceResolver) {
        var styleText = null;
        if (xml.firstChild() != null) {
            styleText = xml.firstChild().nodeValue;
        }

        if (xml.get("source") != null) {
            var source:String = xml.get("source");
            var sourceData:String = resourceResolver.getResourceData(source);
            if (sourceData != null) {
                if (styleText == null) {
                    styleText = "";
                }
                styleText += "\n" + sourceData;
            }
        }

        if (styleText != null) {
            var scope:String = xml.get("scope");
            if (scope == null) {
                scope = "global";
            }
            if (scope == "global") {
                component.findRootComponent().styles.push(new ComponentStyleInfo(styleText, scope));
            } else if (scope == "local" && component.parent != null) {
                component.parent.styles.push(new ComponentStyleInfo(styleText, scope));
            }
        }
    }

    private static function parseLayoutNode(component:ComponentInfo, xml:Xml) {
        var layoutXml:Xml = xml.firstElement();
        var layout:LayoutInfo = new LayoutInfo();
        component.layout = layout;

        layout.type = layoutXml.nodeName;

        for (attrName in layoutXml.attributes()) {
            var attrValue:String = layoutXml.get(attrName);
            layout.properties.set(attrName, attrValue);
        }
    }

    private static function parseDetails(component:ComponentInfo, xml:Xml) {
        if (xml.firstChild() != null && '${xml.firstChild().nodeType}' == "1") {
            var value = StringTools.trim(xml.firstChild().nodeValue);
            if (value != null && value.length > 0) {
                component.text = value;
            }
        }
        component.type = StringTools.replace(xml.nodeName.toLowerCase(), "-", "");
    }

    private static function parseAttributes(component:ComponentInfo, xml:Xml) {
        for (attrName in xml.attributes()) {
            var attrValue:String = xml.get(attrName);
            switch (attrName) {
                case "condition":
                    component.condition = attrValue;
                case "if":
                    var condition = [];
                    for (t in attrValue.split(",")) {
                        condition.push('defined("${StringTools.trim(t)}") == true');
                    }
                    component.condition = condition.join(" || ");
                case "unless":
                    var condition = [];
                    for (t in attrValue.split(",")) {
                        condition.push('defined("${StringTools.trim(t)}") == false');
                    }
                    component.condition = condition.join(" && ");
                case "id":
                    component.id = attrValue;
                case "left":
                    component.left = ComponentParser.float(attrValue);
                case "top":
                    component.top = ComponentParser.float(attrValue);
                case "width":
                    if (ComponentParser.isPercentage(attrValue) == true) {
                        component.percentWidth = ComponentParser.float(attrValue);
                    } else {
                        component.width = ComponentParser.float(attrValue);
                    }
                case "height":
                    if (ComponentParser.isPercentage(attrValue) == true) {
                        component.percentHeight = ComponentParser.float(attrValue);
                    } else {
                        component.height = ComponentParser.float(attrValue);
                    }
                case "contentWidth":
                    if (ComponentParser.isPercentage(attrValue) == true) {
                        component.percentContentWidth = ComponentParser.float(attrValue);
                    } else {
                        component.contentWidth = ComponentParser.float(attrValue);
                    }
                case "contentHeight":
                    if (ComponentParser.isPercentage(attrValue) == true) {
                        component.percentContentHeight = ComponentParser.float(attrValue);
                    } else {
                        component.contentHeight = ComponentParser.float(attrValue);
                    }
                case "text":
                    component.text = attrValue;
                case "style":
                    component.style = attrValue;
                case "styleNames" | "styleName":
                    component.styleNames = attrValue;
                case "composite":
                    component.composite = (attrValue == "true");
                case "layout":
                    component.layoutName = attrValue;
                case "direction":
                    component.direction = attrValue;
                default:
                    component.properties.set(attrName, attrValue);
            }
        }
    }
}
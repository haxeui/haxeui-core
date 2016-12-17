package haxe.ui.parsers.ui;

import haxe.ui.parsers.ui.ComponentInfo.ComponentBindingInfo;
import haxe.ui.parsers.ui.resolvers.ResourceResolver;

class ObjectParser extends ComponentParser {
    public function new() {
        super();
    }

    private function fromObject(obj:Dynamic, resourceResolver:ResourceResolver):ComponentInfo {
        var component:ComponentInfo = new ComponentInfo();
        parseComponent(component, obj, resourceResolver);
        return component;
    }

    private static function parseComponent(component:ComponentInfo, obj:Dynamic, resourceResolver:ResourceResolver) {
        var type = Reflect.fields(obj)[0];

        component.type = type;
        var details = Reflect.field(obj, type);

        if (type == "import") {
            parseImport(component.parent, details, resourceResolver);
            return;
        }

        for (propName in Reflect.fields(details)) {
            var propValue = Reflect.field(details, propName);

            switch (propName) {
                case "id":
                    component.id = propValue;
                case "left":
                    component.left = ComponentParser.float(propValue);
                case "top":
                    component.top = ComponentParser.float(propValue);
                case "width":
                    if (ComponentParser.isPercentage("" + propValue) == true) {
                        component.percentWidth = ComponentParser.float("" + propValue);
                    } else {
                        component.width = ComponentParser.float("" + propValue);
                    }
                case "height":
                    if (ComponentParser.isPercentage("" + propValue) == true) {
                        component.percentHeight = ComponentParser.float("" + propValue);
                    } else {
                        component.height = ComponentParser.float("" + propValue);
                    }
                case "text":
                    component.text = propValue;
                case "style":
                    component.style = propValue;
                case "styleNames":
                    component.styleNames = propValue;
                case "bindTo" | "bindTransform": // do nothing
                case "children":
                    var children:Array<Dynamic> = Reflect.field(details, "children");
                    for (childObj in children) {
                        var child:ComponentInfo = new ComponentInfo();
                        child.parent = component;
                        parseComponent(child, childObj, resourceResolver);
                        if (child.type != "import") {
                            component.children.push(child);
                        }
                    }
                default:
                    component.properties.set(propName, propValue);
            }
        }

        var bindTo:String =  Reflect.field(details, "bindTo");
        if (bindTo != null) {
            if (component.id == null) {
                component.id = ComponentParser.nextId();
            }

            var binding:ComponentBindingInfo = new ComponentBindingInfo();
            binding.source = bindTo;
            binding.target = component.id;
            binding.transform = Reflect.field(details, "bindTransform");
            component.findRootComponent().bindings.push(binding);
        }

    }

    private static function parseImport(component:ComponentInfo, obj:Dynamic, resourceResolver:ResourceResolver) {
        if (obj.source != null) {
            var source:String = obj.source;
            var sourceData:String = resourceResolver.getResourceData(source);
            if (sourceData != null) {
                var extension:String = resourceResolver.extension(source);
                var c:ComponentInfo = ComponentParser.get(extension).parse(sourceData, resourceResolver);

                component.findRootComponent().styles = component.findRootComponent().styles.concat(c.styles);
                c.styles = [];

                component.findRootComponent().scriptlets = component.findRootComponent().scriptlets.concat(c.scriptlets);
                c.scriptlets = [];

                component.findRootComponent().bindings = component.findRootComponent().bindings.concat(c.bindings);
                c.bindings = [];

                c.parent = component;
                component.children.push(c);
            }
        }
    }
}
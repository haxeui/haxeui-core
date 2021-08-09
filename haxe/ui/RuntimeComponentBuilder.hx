package haxe.ui;

import haxe.ui.Toolkit;
import haxe.ui.core.Component;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.layouts.Layout;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.LayoutInfo;
import haxe.ui.parsers.ui.resolvers.AssetResourceResolver;
import haxe.ui.parsers.ui.resolvers.ResourceResolver;
import haxe.ui.util.SimpleExpressionEvaluator;
import haxe.ui.util.TypeConverter;
import haxe.ui.util.Variant;

class RuntimeComponentBuilder {
    public static function fromAsset(assetId:String):Component {
        var data = ToolkitAssets.instance.getText(assetId);
        return fromString(data, null, new AssetResourceResolver(assetId));
    }
    
    public static function fromString(data:String, type:String = null, resourceResolver:ResourceResolver = null, callback:Component->Void = null):Component {
        if (data == null || data.length == 0) {
            return null;
        }

        if (type == null) { // lets try and auto detect
            if (StringTools.startsWith(StringTools.trim(data), "<")) {
                type = "xml";
            }
        }

        var parser:ComponentParser = ComponentParser.get(type);
        if (parser == null) {
            trace('WARNING: type "${type}" not recognised');
            return null;
        }

        var c:ComponentInfo = parser.parse(data, resourceResolver);
        for (style in c.styles) {
            if (style.scope == "global") {
                Toolkit.styleSheet.parse(style.style);
            }
        }
        var component = buildComponentFromInfo(c, callback);

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }

        //component.script = fullScript;

        return component;
    }
    
    private static function buildComponentFromInfo(c:ComponentInfo, callback:Component->Void):Component {
        if (c.condition != null && SimpleExpressionEvaluator.evalCondition(c.condition) == false) {
            return null;
        }

        var className:String = ComponentClassMap.get(c.type.toLowerCase());
        if (className == null) {
            trace("WARNING: no class found for component: " + c.type);
            return null;
        }

        var component:Component = Type.createInstance(Type.resolveClass(className), []);
        if (component == null) {
            trace("WARNING: could not create class instance: " + className);
            return null;
        }

        if (c.id != null)               component.id = c.id;
        if (c.left != null)             component.left = c.left;
        if (c.top != null)              component.top = c.top;
        if (c.width != null)            component.width = c.width;
        if (c.height != null)           component.height = c.height;
        if (c.percentWidth != null)     component.percentWidth = c.percentWidth;
        if (c.percentHeight != null)    component.percentHeight = c.percentHeight;
        if (c.text != null)             component.text = c.text;
        if (c.styleNames != null)       component.styleNames = c.styleNames;
        if (c.style != null)            component.styleString = c.style;
        if (c.layout != null) {
            var layout:Layout = buildLayoutFromInfo(c.layout);
            component.layout = layout;
        }

        if ((component is haxe.ui.containers.ScrollView)) { // special properties for scrollview and derived classes
            var scrollview:haxe.ui.containers.ScrollView = cast(component, haxe.ui.containers.ScrollView);
            if (c.contentWidth != null)             scrollview.contentWidth = c.contentWidth;
            if (c.contentHeight != null)            scrollview.contentHeight = c.contentHeight;
            if (c.percentContentWidth != null)      scrollview.percentContentWidth = c.percentContentWidth;
            if (c.percentContentHeight != null)     scrollview.percentContentHeight = c.percentContentHeight;
        }

        for (propName in c.properties.keys()) {
            var propValue:Dynamic = c.properties.get(propName);
            propName = ComponentFieldMap.mapField(propName);
            if (StringTools.startsWith(propName, "on")) {
                //component.addScriptEvent(propName, propValue);
            } else {
                propValue = TypeConverter.convertFrom(propValue);
                Reflect.setProperty(component, propName, propValue);
            }
        }

        if ((component is IDataComponent) && c.data != null) {
            cast(component, IDataComponent).dataSource = new haxe.ui.data.DataSourceFactory<Dynamic>().fromString(c.dataString, haxe.ui.data.ArrayDataSource);
        }

        for (childInfo in c.children) {
            var childComponent = buildComponentFromInfo(childInfo, callback);
            if (childComponent != null) {
                component.addComponent(childComponent);
            }
        }

        if (callback != null) {
            callback(component);
        }

        return component;
    }

    private static function buildLayoutFromInfo(l:LayoutInfo):Layout {
        var className:String = LayoutClassMap.get(l.type.toLowerCase());
        if (className == null) {
            trace("WARNING: no class found for layout: " + l.type);
            return null;
        }

        var layout:Layout = Type.createInstance(Type.resolveClass(className), []);
        if (layout == null) {
            trace("WARNING: could not create class instance: " + className);
            return null;
        }

        for (propName in l.properties.keys()) {
            var propValue:Dynamic = l.properties.get(propName);
            Reflect.setProperty(layout, propName, Variant.fromDynamic(propValue));
        }

        return layout;
    }
}
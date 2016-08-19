package haxe.ui;

import haxe.ui.core.Component;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.KeyboardEvent;
import haxe.ui.core.Screen;
import haxe.ui.focus.FocusManager;
import haxe.ui.macros.BackendMacros;
import haxe.ui.macros.ModuleMacros;
import haxe.ui.macros.NativeMacros;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.styles.Engine;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.GenericConfig;
import haxe.ui.util.Properties;

class Toolkit {
    public static var styleSheet:Engine = new Engine();
    public static var theme:String = "default";

    public static var properties:Map<String, String> = new Map<String, String>();

    public static var backendProperties:Properties = new Properties();
    public static var nativeConfig:GenericConfig = new GenericConfig();

    private static var _built:Bool = false;
    public static function build() {
        if (_built == true) {
            return;
        }
        BackendMacros.processBackend();
        ModuleMacros.processModules();
        NativeMacros.processNative();
        _built = true;

        #if (haxeui_remoting && !haxeui_remoting_server)
        var client:haxe.ui.remoting.client.Client = new haxe.ui.remoting.client.Client();
        #end
    }

    public static function init(options:Dynamic = null) {
        build();
        ThemeManager.instance.applyTheme(theme);
        if (options != null) {
            screen.options = options;
            ToolkitAssets.instance.options = options;
        }
        screen.registerEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private static function onKeyDown(event:KeyboardEvent) {
        if (event.keyCode == KeyboardEvent.KEY_TAB) {
            if (event.shiftKey == false) {
                FocusManager.instance.focusNext();
            } else {
                FocusManager.instance.focusPrev();
            }
        }
    }

    public static var assets(get, null):ToolkitAssets;
    private static function get_assets():ToolkitAssets {
        return ToolkitAssets.instance;
    }

    public static var screen(get, null):Screen;
    private static function get_screen():Screen {
        return Screen.instance;
    }

    public static function componentFromString(data:String, type:String = null):Component {
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

        var c:ComponentInfo = parser.parse(data);
        var component = buildComponentFromInfo(c);

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }

        component.script = fullScript;

        return component;
    }

    private static function buildComponentFromInfo(c:ComponentInfo):Component {
        var className:String = ComponentClassMap.get(c.type);
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
        for (propName in c.properties.keys()) {
            var propValue:Dynamic = c.properties.get(propName);
            if (StringTools.startsWith(propName, "on")) {
                component.addScriptEvent(propName, propValue);
            } else {
                if (Reflect.hasField(component, propName) == false) {
                    continue;
                }

                if (propValue == "true" || propValue == "yes" || propValue == "false" || propValue == "no") {
                    propValue = (propValue == "true" || propValue == "yes");
                } else if (Std.parseInt(propValue) != null) {
                    propValue = Std.parseInt(propValue);
                }

                Reflect.setField(component, propName, propValue);
            }
        }

        for (childInfo in c.children) {
            var childComponent = buildComponentFromInfo(childInfo);
            if (childComponent != null) {
                component.addComponent(childComponent);
            }
        }

        return component;
    }
}
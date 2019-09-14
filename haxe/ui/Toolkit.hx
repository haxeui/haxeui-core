package haxe.ui;

import haxe.ui.backend.ToolkitOptions;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.core.Component;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.core.ComponentFieldMap;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.LayoutClassMap;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.layouts.Layout;
import haxe.ui.macros.BackendMacros;
import haxe.ui.macros.ModuleMacros;
import haxe.ui.macros.NativeMacros;
import haxe.ui.parsers.ui.ComponentInfo;
import haxe.ui.parsers.ui.ComponentParser;
import haxe.ui.parsers.ui.LayoutInfo;
import haxe.ui.parsers.ui.resolvers.AssetResourceResolver;
import haxe.ui.parsers.ui.resolvers.ResourceResolver;
import haxe.ui.scripting.ConditionEvaluator;
import haxe.ui.styles.CompositeStyleSheet;
import haxe.ui.styles.StyleSheet;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.GenericConfig;
import haxe.ui.util.Properties;
import haxe.ui.util.Variant;

class Toolkit {
    public static var styleSheet:CompositeStyleSheet = new CompositeStyleSheet();
    
    public static var properties:Map<String, String> = new Map<String, String>();

    public static var nativeConfig:GenericConfig = new GenericConfig();

    private static var _theme:String = "default";
    public static var theme(get, set):String;
    private static function get_theme():String {
        return _theme;
    }
    @:access(haxe.ui.core.Screen)
    private static function set_theme(value:String):String {
        if (_theme == value) {
            return value;
        }
        _theme = value;
        if (_initialized == true) {
            ThemeManager.instance.applyTheme(_theme);
            Screen.instance.invalidateAll();
        }
        return value;
    }
    
    private static var _backendProperties:Properties = new Properties();
    public static var backendProperties(get, null):Properties;
    private static function get_backendProperties():Properties {
        buildBackend();
        return _backendProperties;
    }
    
    private static var _built:Bool = false;
    public static function build() {
        if (_built == true) {
            return;
        }
        ModuleMacros.processModules();
        NativeMacros.processNative();
        buildBackend();
        _built = true;
    }

    private static var _backendBuilt:Bool = false;
    private static function buildBackend() {
        if (_backendBuilt == true) {
            return;
        }
        BackendMacros.processBackend();
        _backendBuilt = true;
    }
    
    private static var _initialized:Bool = false;
    public static function init(options:ToolkitOptions = null) {
        build();
        ThemeManager.instance.applyTheme(_theme);
        if (options != null) {
            screen.options = options;
            ToolkitAssets.instance.options = options;
        }
        screen.registerEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
        _initialized = true;
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

    public static function messageBox(message:String, title:String = null, type:MessageBoxType = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        if (type == null) {
            type = MessageBoxType.TYPE_INFO;
        }
        var messageBox = new MessageBox();
        messageBox.type = type;
        messageBox.message = message;
        messageBox.modal = modal;
        if (title != null) {
            messageBox.title = title;
        }
        messageBox.show();
        if (callback != null) {
            messageBox.registerEvent(DialogEvent.DIALOG_CLOSED, function(e:DialogEvent) {
                callback(e.button);
            });
        }
        return messageBox;
    }
  
    public static function dialog(contents:Component, title:String = null, buttons:DialogButton = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        var dialog = new Dialog();
        dialog.modal = modal;
        if (title != null) {
            dialog.title = title;
        }
        if (buttons != null) {
            dialog.buttons = buttons;
        }
        dialog.addComponent(contents);
        dialog.show();
        if (callback != null) {
            dialog.registerEvent(DialogEvent.DIALOG_CLOSED, function(e:DialogEvent) {
                callback(e.button);
            });
        }
        return dialog;
    }
    
    public static var assets(get, null):ToolkitAssets;
    private static function get_assets():ToolkitAssets {
        return ToolkitAssets.instance;
    }

    public static var screen(get, null):Screen;
    private static function get_screen():Screen {
        return Screen.instance;
    }

    public static function componentFromAsset(assetId:String):Component {
        var data = ToolkitAssets.instance.getText(assetId);
        return componentFromString(data, null, new AssetResourceResolver(assetId));
    }

    public static function componentFromString(data:String, type:String = null, resourceResolver:ResourceResolver = null, callback:Component->Void = null):Component {
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
        var component = buildComponentFromInfo(c, callback);

        var fullScript = "";
        for (scriptString in c.scriptlets) {
            fullScript += scriptString;
        }

        component.script = fullScript;

        return component;
    }

    private static function buildComponentFromInfo(c:ComponentInfo, callback:Component->Void):Component {
        if (c.condition != null && new ConditionEvaluator().evaluate(c.condition) == false) {
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
        
        if (Std.is(component, haxe.ui.containers.ScrollView)) { // special properties for scrollview and derived classes
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
                component.addScriptEvent(propName, propValue);
            } else {
                if (propValue == "true" || propValue == "yes" || propValue == "false" || propValue == "no") {
                    propValue = (propValue == "true" || propValue == "yes");
                } else if (Std.parseInt(propValue) != null) {
                    propValue = Std.parseInt(propValue);
                }
                
                Reflect.setProperty(component, propName, propValue);
            }
        }

        if (Std.is(component, IDataComponent) && c.data != null) {
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

    public static var pixelsPerRem(default, set):Int = 16;
    private static function set_pixelsPerRem(value:Int):Int {
        if (pixelsPerRem == value) {
            return value;
        }

        pixelsPerRem = value;
        Screen.instance.refreshStyleRootComponents();

        return value;
    }

    public static var autoScale:Bool = true;
    public static var autoScaleDPIThreshold:Int = 120;

    private static var _scaleX:Float = 0;
    public static var scaleX(get, set):Float;
    private static function get_scaleX():Float {
        if (_scaleX == 0) {
            if (autoScale == true) {
                var dpi:Float = Screen.instance.dpi;
                if (dpi > autoScaleDPIThreshold) {
                    _scaleX = Math.fround(dpi / autoScaleDPIThreshold);
                } else {
                    _scaleX = 1;
                }
            } else {
                _scaleX = 1;
            }
        }
        return _scaleX;
    }
    private static function set_scaleX(value:Float):Float {
        if (_scaleX == value) {
            return value;
        }
        _scaleX = value;
        autoScale = false;
        return value;
    }

    private static var _scaleY:Float = 0;
    public static var scaleY(get, set):Float;
    private static function get_scaleY():Float {
        if (_scaleY == 0) {
            if (autoScale == true) {
                var dpi:Float = Screen.instance.dpi;
                if (dpi > autoScaleDPIThreshold) {
                    _scaleY = Math.fround(dpi / autoScaleDPIThreshold);
                } else {
                    _scaleY = 1;
                }
            } else {
                _scaleY = 1;
            }
        }
        return _scaleY;
    }
    private static function set_scaleY(value:Float):Float {
        if (_scaleY == value) {
            return value;
        }
        _scaleY = value;
        autoScale = false;
        return value;
    }

    public static var scale(get, set):Float;
    private static function get_scale():Float {
        return Math.max(scaleX, scaleY);
    }
    private static function set_scale(value:Float):Float {
        scaleX = value;
        scaleY = value;
        return value;
    }
    
    public static function callLater(fn:Void->Void) {
        new CallLater(fn);
    }
}
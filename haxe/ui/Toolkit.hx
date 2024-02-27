package haxe.ui;

import haxe.ui.backend.ToolkitOptions;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.macros.BackendMacros;
import haxe.ui.macros.ModuleMacros;
import haxe.ui.macros.NativeMacros;
import haxe.ui.styles.CompositeStyleSheet;
import haxe.ui.themes.ThemeManager;
import haxe.ui.util.GenericConfig;
import haxe.ui.util.Properties;

#if !haxe4
#error "HaxeUI requires Haxe 4+"
#end

#if haxeui_expose_all
@:expose
#end
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
            Screen.instance.onThemeChanged();
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
        haxe.ui.locale.LocaleManager.instance.init();
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
    public static var initialized(get, null):Bool;
    private static function get_initialized():Bool {
        return _initialized;
    }
    
    public static var onBeforeInit:Void->Void = null;
    public static var onAfterInit:Void->Void = null;
    
    public static function init(options:ToolkitOptions = null) {
        if (onBeforeInit != null) {
            onBeforeInit();
        }
        build();
        ThemeManager.instance.applyTheme(_theme);
        if (options != null) {
            screen.options = options;
            ToolkitAssets.instance.options = options;
        }
        screen.registerEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
        _initialized = true;
        if (onAfterInit != null) {
            onAfterInit();
        }
    }

    private static function onKeyDown(event:KeyboardEvent) {
        if (event.keyCode == Platform.instance.KeyTab) {
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

    public static var pixelsPerRem(default, set):Int = 16;
    private static function set_pixelsPerRem(value:Int):Int {
        if (pixelsPerRem == value) {
            return value;
        }

        pixelsPerRem = value;
        Screen.instance.refreshStyleRootComponents();

        return value;
    }

    public static var roundScale:Bool = true;
    public static var autoScale:Bool = true;
    public static var autoScaleDPIThreshold(get, null):Int;
    private static function get_autoScaleDPIThreshold():Int {
        if (Screen.instance.isRetina == true) {
            return 192;
        }
        return 120;
    }

    private static var _scaleX:Float = 0;
    public static var scaleX(get, set):Float;
    private static function get_scaleX():Float {
        if (_scaleX == 0) {
            if (autoScale == true) {
                var dpi:Float = Screen.instance.dpi;
                if (dpi > autoScaleDPIThreshold) {
                    if (roundScale == true) {
                        _scaleX = Math.fround(dpi / autoScaleDPIThreshold);
                    } else {
                        _scaleX = dpi / autoScaleDPIThreshold;
                    }
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
                    if (roundScale == true) {
                        _scaleY = Math.fround(dpi / autoScaleDPIThreshold);
                    } else {
                        _scaleY = dpi / autoScaleDPIThreshold;
                    }
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
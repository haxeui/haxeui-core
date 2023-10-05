package haxe.ui.locale;

import haxe.ui.ToolkitAssets;
import haxe.ui.core.Component;
import haxe.ui.core.Platform;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleEvent;
import haxe.ui.parsers.locale.LocaleParser;
import haxe.ui.util.EventMap;
import haxe.ui.util.ExpressionUtil;
import haxe.ui.util.MathUtil;
import haxe.ui.util.SimpleExpressionEvaluator;

using StringTools;

typedef ComponentLocaleEntry = {
    @:optional var callback:Void->Dynamic;
    @:optional var expr:String;
}

@:keep
class LocaleManager {
    private static var _instance:LocaleManager;
    public static var instance(get, never):LocaleManager;
    private static function get_instance():LocaleManager {
        if (_instance == null) {
            _instance = new LocaleManager();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    
    private var _eventMap:EventMap = null;
    
    private function new() {
    }

    public function init() {
        #if !haxeui_dont_detect_locale
        var autoDetectedLocale = Platform.instance.getSystemLocale();
        if (!_localeSet && autoSetLocale && autoDetectedLocale != null && hasLocale(autoDetectedLocale)) {
            #if debug
            trace("DEBUG: System locale detected as: " + autoDetectedLocale);
            #end
            _language = autoDetectedLocale;
            applyLocale(_language);
        }
        #end
    }
    
    private static var _registeredComponents:Map<Component, Map<String, ComponentLocaleEntry>> = new Map<Component, Map<String, ComponentLocaleEntry>>();
    public function registerComponent(component:Component, prop:String, callback:Void->Dynamic = null, expr:String = null, fix:Bool = true) {
        if (callback == null && expr == null) {
            return;
        }
        
        var fixedExpr:String = null;
        if (fix == true) {
            if (expr != null) {
                fixedExpr = ExpressionUtil.stringToLanguageExpression(expr, "LocaleManager");
                if (StringTools.endsWith(fixedExpr, ";") == true) {
                    fixedExpr = fixedExpr.substr(0, fixedExpr.length - 1);
                }
            }
        } else {
            fixedExpr = expr;
        }
        
        var propMap = _registeredComponents.get(component);
        if (propMap == null) {
            propMap = new Map<String, ComponentLocaleEntry>();
            _registeredComponents.set(component, propMap);
        }
        propMap.set(prop, {
            callback: callback,
            expr: fixedExpr
        });
        refreshFor(component);
    }
    
    public function unregisterComponent(component:Component) {
        _registeredComponents.remove(component);
    }
    
    public function findBindingExpr(component:Component, prop:String):String {
        var propMap = _registeredComponents.get(component);
        if (propMap == null) {
            return null;
        }
        
        var entry = propMap.get(prop);
        if (entry == null) {
            return null;
        }
        return entry.expr;
    }
    
    public function cloneForComponent(from:Component, to:Component) {
        var propMap = _registeredComponents.get(from);
        if (propMap == null) {
            return;
        }
        
        for (prop in propMap.keys()) {
            var entry = propMap.get(prop);
            registerComponent(to, prop, entry.callback, entry.expr, false);
        }
    }
    
    private function onComponentReady(e:UIEvent) {
        e.target.unregisterEvent(UIEvent.READY, onComponentReady);
        refreshFor(e.target);
    }
    
    public function refreshFor(component:Component) {
        if (component.isReady == false) {
            component.registerEvent(UIEvent.READY, onComponentReady);
            return;
        }
        
        var propMap = _registeredComponents.get(component);
        if (propMap == null) {
            return;
        }

        var context = {
            LocaleManager: LocaleManager,
            MathUtil: MathUtil
        }

        var root = findRoot(component);
        for (k in root.namedComponents) {
            if (k.scriptAccess == false) {
                continue;
            }
            Reflect.setField(context, k.id, k);
        }
        
        
        for (prop in propMap.keys()) {
            var entry = propMap.get(prop);
            if (entry.callback != null) {
                var value = entry.callback();
                Reflect.setProperty(component, prop, value);
            } else if (entry.expr != null) {
                var value = SimpleExpressionEvaluator.eval(entry.expr, context);
                Reflect.setProperty(component, prop, value);
            }
        }
    }
    
    public function refreshAll() {
        for (c in _registeredComponents.keys()) {
            refreshFor(c);
        }
    }
    
    public var autoSetLocale:Bool = true;

    private var _localeSet:Bool = false;
    private var _language:String = "en";
    public var language(get, set):String;
    private function get_language():String {
        return _language;
    }
    private function set_language(value:String):String {
        if (value == null) {
            return value;
        }
        if (_language == value) {
            return value;
        }

        _localeSet = true;
        _language = value;

        applyLocale(_language);
        return value;
    }

    private function applyLocale(locale:String) {
        if (getStrings(locale) == null) {
            //return value;
        }
        
        refreshAll();
        if (_eventMap != null) {
            var event = new LocaleEvent(LocaleEvent.LOCALE_CHANGED);
            _eventMap.invoke(LocaleEvent.LOCALE_CHANGED, event);
        }
    }

    public function hasLocale(localeId:String):Bool {
        localeId = StringTools.replace(localeId, "-", "_");
        if (_localeMap.exists(localeId)) {
            return true;
        }

        var parts = localeId.split("_");
        return _localeMap.exists(parts[0]);
    }
    
    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (_eventMap == null) {
            _eventMap = new EventMap();
        }
        _eventMap.add(type, listener, priority);
    }

    public function hasEvent(type:String, listener:Dynamic->Void = null):Bool {
        if (_eventMap == null) {
            return false;
        }
        return _eventMap.contains(type, listener);
    }
    

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_eventMap != null) {
            _eventMap.remove(type, listener);
        }
    }
    
    public function parseResource(localeId:String, resourceId:String) {
        var content = ToolkitAssets.instance.getText(resourceId);
        if (content != null) {
            var parts = resourceId.split(".");
            var extension = parts.pop();
            var filename = parts.join(".");
            var n = filename.lastIndexOf("/");
            if (n != -1) {
                filename = filename.substr(n + 1);
            }
            var parser = LocaleParser.get(extension);
            var map = parser.parse(content);
            addStrings(localeId, map, filename);
        }
    }
    
    private var _localeMap:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
    public function addStrings(localeId:String, map:Map<String, String>, filename:String = null) {
        localeId = StringTools.replace(localeId, "-", "_");
        var stringMap = _localeMap.get(localeId);
        if (stringMap == null) {
            stringMap = new Map<String, String>();
            _localeMap.set(localeId, stringMap);
        }
        for (k in map.keys()) {
            var v = map.get(k);
            if (filename != null && filename != localeId && StringTools.startsWith(k, filename) == false) {
                var altKey = filename + "." + k;
                stringMap.set(altKey, v);
            }
            stringMap.set(k, v);
        }
        
        localeId = StringTools.replace(localeId, "-", "_");
        var parts = localeId.split("_");
        if (parts.length > 1) {
            var parent = _localeMap.get(parts[0]);
            if (parent != null) {
                for (k in parent.keys()) {
                    if (stringMap.exists(k) == false) {
                        stringMap.set(k, parent.get(k));
                    }
                }
            }
        }
    }
    
    private function getStrings(localeId:String):Map<String, String> {
        var strings = _localeMap.get(localeId);
        if (strings != null) {
            return strings;
        }
        
        localeId = StringTools.replace(localeId, "-", "_");
        var parts = localeId.split("_");
        if (!_localeMap.exists(parts[0])) {
            return _localeMap.get("en");
        }
        return _localeMap.get(parts[0]);
    }
    
    public function hasString(id:String):Bool {
        var strings = getStrings(language);
        if (strings == null) {
            return false;
        }
        return strings.exists(id);
    }
    
    public function lookupString(id:String, param0:Any = null, param1:Any = null, param2:Any = null, param3:Any = null) {
        return translateTo(language, id, param0, param1, param2, param3);
    }

    private var _localeStringMap:Map<String, Map<String, LocaleString>> = new Map<String, Map<String, LocaleString>>();
    public function translateTo(lang:String, id:String, param0:Any = null, param1:Any = null, param2:Any = null, param3:Any = null) {
        lang = StringTools.replace(lang, "-", "_");
        var map = _localeStringMap.get(lang);
        var localeString:LocaleString = null;
        if (map != null) {
            localeString = map.get(id);
        }

        if (localeString == null) {
            var strings = getStrings(lang);
            if (strings == null) {
                return id;
            }
            var value = strings.get(id);
            if (value == null) {
                return id;
            }

            // this means its a compound string, ie, translates string that refs another string:
            //     X=test1
            //     Y=test2 {{X}}
            //     Z=test3 {{X}} {{Y}}
            // this also means we cant really cache it, so in these cases, we will completely
            // build the string from scratch again and again
            var isCompound = false;
            if (value.indexOf("{{") != -1 && value.indexOf("}}") != -1) {
                isCompound = true;
                var n1 = value.indexOf("{{");
                while (n1 != -1) {
                    var n2 = value.indexOf("}}", n1);
                    var before = value.substring(0, n1);
                    var part = value.substring(n1 + 2, n2);
                    var after = value.substring(n2 + 2);

                    var partValue = translateTo(lang, part, param0, param1, param2, param3);
                    value = before + partValue + after;

                    n1 = value.indexOf("{{", n1);
                }
            }

            localeString = new LocaleString();
            localeString.parse(id + "=" + value);

            if (!isCompound) {
                if (map == null) {
                    map = new Map<String, LocaleString>();
                    _localeStringMap.set(lang, map);
                }
                map.set(id, localeString);
            }
        }

        var result = localeString.build(param0, param1, param2, param3);
        return result;
    }
    
    private function findRoot(c:Component):Component {
        var root = c;

        var ref = c;
        while (ref != null) {
            root = ref;
            if (root.bindingRoot) {
                break;
            }
            ref = ref.parentComponent;
        }

        return root;
    }
}

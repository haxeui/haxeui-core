package haxe.ui.locale;

import haxe.ui.ToolkitAssets;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleEvent;
import haxe.ui.parsers.locale.LocaleParser;
import haxe.ui.util.EventMap;
import haxe.ui.util.ExpressionUtil;
import haxe.ui.util.MathUtil;
import haxe.ui.util.SimpleExpressionEvaluator;

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
        e.target.unregisterEvent(UIEvent.INITIALIZE, onComponentReady);
        refreshFor(e.target);
    }
    
    public function refreshFor(component:Component) {
        if (component.isReady == false) {
            component.registerEvent(UIEvent.INITIALIZE, onComponentReady);
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

        if (getStrings(value) == null) {
            //return value;
        }
        
        _language = value;
        refreshAll();
        if (_eventMap != null) {
            var event = new LocaleEvent(LocaleEvent.LOCALE_CHANGED);
            _eventMap.invoke(LocaleEvent.LOCALE_CHANGED, event);
        }
        return value;
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

	public function translateTo(lang:String, id:String, param0:Any = null, param1:Any = null, param2:Any = null, param3:Any = null) {
        var strings = getStrings(lang);
        if (strings == null) {
            return id;
        }
        var value = strings.get(id);
        if (value == null) {
            return id;
        }
        
        if (param0 != null) value = StringTools.replace(value, "{0}", param0);
        if (param1 != null) value = StringTools.replace(value, "{1}", param1);
        if (param2 != null) value = StringTools.replace(value, "{2}", param2);
        if (param3 != null) value = StringTools.replace(value, "{3}", param3);
        
        return value;
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

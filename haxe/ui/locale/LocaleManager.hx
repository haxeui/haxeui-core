package haxe.ui.locale;

import haxe.ui.core.UIEvent;
import haxe.ui.util.EventMap;
using StringTools;

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
    private var _locales:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
    private var _currentLocale:Map<String, String>;
    private var _currentLocaleID:String;

    public function new() {

    }

    /**
     Get all locales registered
    **/
    public function getLocales():Array<String> {
        var result:Array<String> = [];
        for (k in _locales.keys()) {
            result.push(k);
        }

        return result;
    }

    /**
      Register a new language in the system
    **/
    public function registerLanguage(id:String, content:Map<String, String>) {
        id = id.toLowerCase();
        _locales.set(id, content);
        if (_currentLocaleID == null) {
            setLanguage(id);
        }
    }

    /**
      Unregister a language in the system
    **/
    public function unregisterLanguage(id:String) {
        id = id.toLowerCase();
        _locales.remove(id);
        if (_currentLocaleID == id) {
            for (k in _locales.keys()) {
                setLanguage(k);
                break;
            }

            if (_currentLocaleID == id) {
                setLanguage(null);
            }
        }
    }

    /**
      Change the language in the system
    **/
    public function setLanguage(id:String):Bool {
        var values = _getLocaleValues(id);
        for (value in values) {
            _currentLocale = _locales.get(value);
            if (_currentLocale != null) {
                _currentLocaleID = value;
                dispatch(new UIEvent(UIEvent.CHANGE));

                return true;
            }
        }

        _currentLocale = new Map<String, String>();
        _currentLocaleID = null;

        return false;
    }

    /**
      Get the locale string with optional `params` from the string `id`.
    **/
    public function get(key:String, params:Array<Any> = null):String {
        var content:String = null;
        if (_currentLocale != null) {
            content = _currentLocale.get(key);

            if (content == null) {
                trace('Invalid locale key ${key} with id ${_currentLocaleID}');
            } else if (params != null) {
                for (i in 0...params.length) {
                    content = content.replace('{${i}}', '${params[i]}');
                }
            }
        }

        return content;
    }

    private function _getLocaleValues(id:String):Array<String> {
        id = id.toLowerCase();
        var localeEReg = ~/([a-zA-Z0-9]+)([-_]([a-zA-Z0-9]+))?/;
        if (localeEReg.match(id)) {
            var locale1 = localeEReg.matched(1);
            var locale2 = localeEReg.matched(3);
            if (locale2 == null) {
                locale2 = locale1;
            }

            return ['${locale1}_${locale2}', '${locale1}-${locale2}', locale1];
        } else {
            return [id];
        }
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function registerEvent(type:String, listener:Dynamic->Void) {
        if (__events == null) {
            __events = new EventMap();
        }

        __events.add(type, listener);
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (__events != null) {
            __events.remove(type, listener);
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function dispatch(event:UIEvent) {
        if (__events != null) {
            __events.invoke(event.type, event);
        }
    }
}
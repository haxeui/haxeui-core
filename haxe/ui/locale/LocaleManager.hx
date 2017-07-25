package haxe.ui.locale;

import haxe.ui.core.UIEvent;
import haxe.ui.util.EventMap;
using StringTools;

typedef Locale = {
    id:String,
    content:Map<String, String>
};

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
    private var _locales:Map<String, Locale> = new Map<String, Locale>();
    private var _currentLocales:Array<Locale>;

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
        id = _normalizeLocaleID(id);

        var locale:Locale = null;
        if (_locales.exists(id)) {
            locale = _locales.get(id);
        } else {
            locale = {id: id, content: new Map<String, String>()};
            _locales.set(id, locale);
        }

        _copyMap(content, locale.content);

        if (_currentLocales == null || _currentLocales.length == 0) {
            setLanguage(id);
        } else if (_getLocaleData(_currentLocales[0].id).language == _getLocaleData(id).language){
            _currentLocales.push(locale);
        }
    }

    /**
      Unregister a language in the system
    **/
    public function unregisterLanguage(id:String) {
        id = _normalizeLocaleID(id);
        var localeRemoved = _locales.get(id);
        _locales.remove(id);

        if (_currentLocales.length > 0) {
            var i:Int = _currentLocales.length;
            while (--i >= 0) {
                if(_currentLocales[i] == localeRemoved) {
                    _currentLocales.splice(i, 1);
                    break;
                }
            }

            if (_currentLocales.length == 0) {
                _setFirstLanguage();
            }
        }
    }

    /**
      Change the language in the system
    **/
    public function setLanguage(id:String):Bool {
        id = _normalizeLocaleID(id);

        if (_currentLocales != null) {
            for (locale in _currentLocales) {
                if (locale.id == id) {
                    return true;
                }
            }
        }

        _currentLocales = [];
        var localeData:LocaleData = _getLocaleData(id);
        for (key in _locales.keys()) {
            if (key.startsWith(localeData.language) || key == id) {
                _currentLocales.push(_locales.get(key));
            }
        }

        if (_currentLocales.length > 0) {
            dispatch(new UIEvent(UIEvent.CHANGE));
        }

        return _currentLocales.length > 0;
    }

    /**
      Get the locale string with optional `params` from the string `id`.
    **/
    public function get(key:String, params:Array<Any> = null):String {
        var localeString:String = null;
        if (_currentLocales != null) {
            for (locale in _currentLocales) {
                localeString = locale.content.get(key);
                if (localeString != null) {
                    if (params != null) {
                        for (i in 0...params.length) {
                            localeString = localeString.replace('{${i}}', '${params[i]}');
                        }
                    }

                    break;
                }
            }

            if (localeString == null) {
                trace('Invalid locale key ${key}');
            }
        }

        return localeString;
    }

    private function _copyMap(fromMap:Map<String, String>, toMap:Map<String, String>) {
        for (key in fromMap.keys()) {
            toMap.set(key, fromMap.get(key));
        }
    }

    private function _getLocaleData(id:String):LocaleData {
        id = _normalizeLocaleID(id);
        var localeEReg = ~/([a-zA-Z0-9]+)(_([a-zA-Z0-9]+))?/;
        var language:String = null;
        var country:String = null;
        if (localeEReg.match(id)) {
            language = localeEReg.matched(1);
            country = localeEReg.matched(3);
        }

        return {language: language, country: country};
    }

    private inline function _normalizeLocaleID(id:String):String {
        return id.toLowerCase().replace("-", "_");
    }

    private function _setFirstLanguage() {
        for (k in _locales.keys()) {
            setLanguage(k);
            break;
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

private typedef LocaleData = {
    language:String,
    ?country:String
}
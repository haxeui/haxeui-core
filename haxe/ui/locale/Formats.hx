package haxe.ui.locale;

class Formats {
    private static var _dateFormatShort:String = null;
    public static var dateFormatShort(get, set):String;
    private static function get_dateFormatShort():String {
        if (_dateFormatShort == null) {
            return getLocaleString("formats.date.short", "%d/%m/%Y");
        }
        return _dateFormatShort;
    }
    private static function set_dateFormatShort(value:String):String {
        _dateFormatShort = value;
        return value;
    }
    
    private static var _decimalSeparator:String = null;
    public static var decimalSeparator(get, set):String;
    private static function get_decimalSeparator():String {
        if (_decimalSeparator == null) {
            return getLocaleString("formats.decimal.separator", ".");
        }
        return _decimalSeparator;
    }
    private static function set_decimalSeparator(value:String):String {
        _decimalSeparator = value;
        return value;
    }
    
    private static var _thousandsSeparator:String = null;
    public static var thousandsSeparator(get, set):String;
    private static function get_thousandsSeparator():String {
        if (_thousandsSeparator == null) {
            return getLocaleString("formats.thousands.separator", ",");
        }
        return _thousandsSeparator;
    }
    private static function set_thousandsSeparator(value:String):String {
        _thousandsSeparator = value;
        return value;
    }

    private static function getLocaleString(id:String, ?defaultString:String) {
        var localeString = LocaleManager.instance.lookupString(id);
        if (localeString == id && defaultString != null) {
            return defaultString;
        }
        return localeString;
    }
}
package haxe.ui.locale;

class Formats {
    private static var _dateFormatShort:String = null;
    public static var dateFormatShort(get, set):String;
    private static function get_dateFormatShort():String {
        if (_dateFormatShort == null) {
            return LocaleManager.instance.lookupString("formats.date.short");
        }
        return _dateFormatShort;
    }
    private static function set_dateFormatShort(value:String):String {
        _dateFormatShort = value;
        return value;
    }
    
    private static var _decimalSeperator:String = null;
    public static var decimalSeperator(get, set):String;
    private static function get_decimalSeperator():String {
        if (_decimalSeperator == null) {
            return LocaleManager.instance.lookupString("formats.decimal.seperator");
        }
        return _decimalSeperator;
    }
    private static function set_decimalSeperator(value:String):String {
        _decimalSeperator = value;
        return value;
    }
    
    private static var _thousandsSeperator:String = null;
    public static var thousandsSeperator(get, set):String;
    private static function get_thousandsSeperator():String {
        if (_thousandsSeperator == null) {
            return LocaleManager.instance.lookupString("formats.thousands.seperator");
        }
        return _thousandsSeperator;
    }
    private static function set_thousandsSeperator(value:String):String {
        _thousandsSeperator = value;
        return value;
    }
}
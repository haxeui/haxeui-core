package haxe.ui.locale;

import haxe.ui.events.UIEvent;

class LocaleEvent extends UIEvent {
    public static inline var LOCALE_CHANGED:String = "localeChanged";

    public function new(type:String) {
        super(type);
    }

    public override function clone():LocaleEvent {
        var c:LocaleEvent = new LocaleEvent(this.type);
        return c;
    }
}
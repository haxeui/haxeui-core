package haxe.ui.events;
import haxe.ui.events.UIEvent;

class ThemeEvent extends UIEvent {
    public static final THEME_CHANGED:EventType<ThemeEvent> = EventType.name("themechanged");
}
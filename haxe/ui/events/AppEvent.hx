package haxe.ui.events;

class AppEvent extends UIEvent {
    public static final APP_READY:EventType<AppEvent> = EventType.name("appready");
    public static final APP_STARTED:EventType<AppEvent> = EventType.name("appstarted");
    public static final APP_CLOSED:EventType<AppEvent> = EventType.name("appclosed");
    public static final APP_EXITED:EventType<AppEvent> = EventType.name("appexited");
}
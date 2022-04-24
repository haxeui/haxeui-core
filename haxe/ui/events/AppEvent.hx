package haxe.ui.events;

class AppEvent extends UIEvent {
    public static inline var APP_READY:String = "appready";
    public static inline var APP_STARTED:String = "appstarted";
    public static inline var APP_CLOSED:String = "appclosed";
    public static inline var APP_EXITED:String = "appexited";
}
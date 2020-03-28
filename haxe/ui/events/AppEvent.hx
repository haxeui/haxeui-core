package haxe.ui.events;

class AppEvent extends UIEvent {
    public static inline var APP_READY:String = "appReady";
    public static inline var APP_STARTED:String = "appStarted";
    public static inline var APP_CLOSED:String = "appClosed";
    public static inline var APP_EXITED:String = "appExited";
}
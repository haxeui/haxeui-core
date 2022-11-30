package haxe.ui.containers.windows;

import haxe.ui.events.UIEvent;

class WindowEvent extends UIEvent {
    public static inline var WINDOW_MINIMIZED = "windowminimized";
    public static inline var WINDOW_MAXIMIZED = "windowmaximized";
    public static inline var WINDOW_RESTORED = "windowrestored";
    public static inline var WINDOW_CLOSED = "windowclosed";
    public static inline var WINDOW_ACTIVATED = "windowactivated";
    public static inline var WINDOW_DEACTIVATED = "windowdeactivated";
    public static inline var WINDOW_ADDED = "windowadded";
    public static inline var WINDOW_REMOVED = "windowremoved";

    public var window(get, null):Window;
    private function get_window():Window {
        return cast target;
    }
}
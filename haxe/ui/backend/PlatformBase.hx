package haxe.ui.backend;

class PlatformBase {
    private static inline var KEY_CODE_TAB:Int   = 9;
    private static inline var KEY_CODE_UP:Int    = 38;
    private static inline var KEY_CODE_DOWN:Int  = 40;
    private static inline var KEY_CODE_LEFT:Int  = 37;
    private static inline var KEY_CODE_RIGHT:Int = 39;
    private static inline var KEY_CODE_SPACE:Int = 32;
    private static inline var KEY_CODE_ENTER:Int = 13;
    
    public function new() {
    }

    public function getMetric(id:String):Float {
        return 0;
    }

    public function getColor(id:String):Null<Int> {
        return null;
    }
    
    public function getSystemLocale():String {
        return null;
    }
    
    public function perf():Float {
        return haxe.Timer.stamp() * 1000;
    }
    
    // shortcuts for key code lookups
    public var KEY_TAB(get, null):Int;
    private inline function get_KEY_TAB():Int {
        return getKeyCode("tab");
    }

    public var KEY_UP(get, null):Int;
    private inline function get_KEY_UP():Int {
        return getKeyCode("up");
    }

    public var KEY_DOWN(get, null):Int;
    private inline function get_KEY_DOWN():Int {
        return getKeyCode("down");
    }
    
    public var KEY_LEFT(get, null):Int;
    private inline function get_KEY_LEFT():Int {
        return getKeyCode("left");
    }
    
    public var KEY_RIGHT(get, null):Int;
    private inline function get_KEY_RIGHT():Int {
        return getKeyCode("right");
    }
    
    public var KEY_SPACE(get, null):Int;
    private inline function get_KEY_SPACE():Int {
        return getKeyCode("space");
    }
    
    public var KEY_ENTER(get, null):Int;
    private inline function get_KEY_ENTER():Int {
        return getKeyCode("enter");
    }
    
    // keycodes can be frameworks specific, having them here
    // means that each PlatformImpl has the ability to override
    // this function and substitute any differences
    public function getKeyCode(keyId:String):Int {
        return switch (keyId) {
            case "tab":   KEY_CODE_TAB;
            case "up":    KEY_CODE_UP;
            case "down":  KEY_CODE_DOWN;
            case "left":  KEY_CODE_LEFT;
            case "right": KEY_CODE_RIGHT;
            case "space": KEY_CODE_SPACE;
            case "enter": KEY_CODE_ENTER;
            case _: keyId.charCodeAt(0);
        }
    }
}
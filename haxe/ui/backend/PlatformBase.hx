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
    public var KeyTab(get, null):Int;
    private inline function get_KeyTab():Int {
        return getKeyCode("tab");
    }

    public var KeyUp(get, null):Int;
    private inline function get_KeyUp():Int {
        return getKeyCode("up");
    }

    public var KeyDown(get, null):Int;
    private inline function get_KeyDown():Int {
        return getKeyCode("down");
    }
    
    public var KeyLeft(get, null):Int;
    private inline function get_KeyLeft():Int {
        return getKeyCode("left");
    }
    
    public var KeyRight(get, null):Int;
    private inline function get_KeyRight():Int {
        return getKeyCode("right");
    }
    
    public var KeySpace(get, null):Int;
    private inline function get_KeySpace():Int {
        return getKeyCode("space");
    }
    
    public var KeyEnter(get, null):Int;
    private inline function get_KeyEnter():Int {
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
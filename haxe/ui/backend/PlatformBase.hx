package haxe.ui.backend;

class PlatformBase {
    private static inline var KEY_CODE_TAB:Int    = 9;
    private static inline var KEY_CODE_UP:Int     = 38;
    private static inline var KEY_CODE_DOWN:Int   = 40;
    private static inline var KEY_CODE_LEFT:Int   = 37;
    private static inline var KEY_CODE_RIGHT:Int  = 39;
    private static inline var KEY_CODE_SPACE:Int  = 32;
    private static inline var KEY_CODE_ENTER:Int  = 13;
    private static inline var KEY_CODE_ESCAPE:Int = 27;
    
    public function new() {
    }

    public var isWindows(get, null):Bool;
    private function get_isWindows():Bool {
        #if sys
        return Sys.systemName().toLowerCase().indexOf("windows") != -1;
        #elseif js
        return js.Browser.window.navigator.userAgent.toLowerCase().indexOf("windows") != -1;
        #end
        return false;
    }
    
    public var isLinux(get, null):Bool;
    private function get_isLinux():Bool {
        #if sys
        return Sys.systemName().toLowerCase().indexOf("linux") != -1;
        #elseif js
        return js.Browser.window.navigator.userAgent.toLowerCase().indexOf("linux") != -1;
        #end
        return false;
    }
    
    public var isMac(get, null):Bool;
    private function get_isMac():Bool {
        #if sys
        return Sys.systemName().toLowerCase().indexOf("mac") != -1;
        #elseif js
        return js.Browser.window.navigator.userAgent.toLowerCase().indexOf("mac") != -1;
        #end
        return false;
    }
    
    #if js
    private static var MOBILE_REGEXP = new EReg("(android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows ce|xda|xiino", "gi");
    #end
    
    private var _isMobile:Null<Bool> = null;
    public var isMobile(get, null):Bool;
    private function get_isMobile():Bool {
        #if mobile
        return true;
        #end
        
        if (_isMobile != null) {
            return _isMobile;
        }
        
        _isMobile = false;
        
        #if js
        
        var ua = js.Browser.navigator.userAgent;
        _isMobile = MOBILE_REGEXP.match(ua);
        
        #end
        
        return _isMobile;
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
    
    public var KeyEscape(get, null):Int;
    private inline function get_KeyEscape():Int {
        return getKeyCode("escape");
    }
    
    // keycodes can be frameworks specific, having them here
    // means that each PlatformImpl has the ability to override
    // this function and substitute any differences
    public function getKeyCode(keyId:String):Int {
        return switch (keyId) {
            case "tab":    KEY_CODE_TAB;
            case "up":     KEY_CODE_UP;
            case "down":   KEY_CODE_DOWN;
            case "left":   KEY_CODE_LEFT;
            case "right":  KEY_CODE_RIGHT;
            case "space":  KEY_CODE_SPACE;
            case "enter":  KEY_CODE_ENTER;
            case "escape": KEY_CODE_ESCAPE;
            case _: keyId.charCodeAt(0);
        }
    }
}
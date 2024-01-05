package haxe.ui.styles;

import haxe.ui.core.Component;
import haxe.ui.styles.elements.Directive;

class DirectiveHandler {
    public function new() {
    }

    public function apply(component:Component, directive:Directive) {
        
    }

    private static var _directiveHandlers:Map<String, Void->DirectiveHandler> = new Map<String, Void->DirectiveHandler>();
    private static var _directiveHandlerInstances:Map<String, DirectiveHandler> = new Map<String, DirectiveHandler>();
    public static function registerDirectiveHandler(name:String, ctor:Void->DirectiveHandler) {
        _directiveHandlers.set(name, ctor);
    }

    public static inline function hasDirectiveHandler(name:String):Bool {
        return _directiveHandlers.exists(name);
    }

    public static inline function getDirectiveHandler(name:String):DirectiveHandler {
        var instance = _directiveHandlerInstances.get(name);
        if (instance != null) {
            return instance;
        }
        var ctor = _directiveHandlers.get(name);
        if (ctor == null) {
            return null;
        }

        instance = ctor();
        // will single instance be fine? These handlers shouldnt be complex and should generally just be setting properties on components
        _directiveHandlerInstances.set(name, instance);
        return instance;
    }
}
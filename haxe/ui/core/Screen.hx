package haxe.ui.core;

import haxe.ui.backend.ScreenImpl;
import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.EventMap;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

class Screen extends ScreenImpl {

    private static var _instance:Screen;
    public static var instance(get, never):Screen;
    private static function get_instance():Screen {
        if (_instance == null) {
            _instance = new Screen();
        }
        return _instance;
    }

    //***********************************************************************************************************
    // Instance
    //***********************************************************************************************************
    private var _eventMap:EventMap;

    public var currentMouseX:Float = 0;
    public var currentMouseY:Float = 0;
    
    public function new() {
        super();
        rootComponents = [];

        _eventMap = new EventMap();
        registerEvent(MouseEvent.MOUSE_MOVE, function(e:MouseEvent) {
            currentMouseX = e.screenX;
            currentMouseY = e.screenY;
        });
    }

    public override function addComponent(component:Component):Component {
        var wasReady = component.isReady;
        @:privateAccess component._hasScreen = true;
        super.addComponent(component);
        #if !(haxeui_javafx || haxeui_android)
        component.ready();
        #end
        if (rootComponents.indexOf(component) == -1) {
            rootComponents.push(component);
        }
        FocusManager.instance.pushView(component);
        if (component.hasEvent(UIEvent.RESIZE, _onRootComponentResize) == false) {
            component.registerEvent(UIEvent.RESIZE, _onRootComponentResize);
        }
        
        if (wasReady && component.hidden == false) {
            component.dispatch(new UIEvent(UIEvent.SHOWN));
        }
        
        return component;
    }

    public override function removeComponent(component:Component, dispose:Bool = true):Component {
        if (rootComponents.indexOf(component) == -1) {
            return component;
        }
        @:privateAccess component._hasScreen = false;
        super.removeComponent(component, dispose);
        component.depth = -1;
        rootComponents.remove(component);
        FocusManager.instance.removeView(component);
        component.unregisterEvent(UIEvent.RESIZE, _onRootComponentResize);
        if (dispose == true) {
            component.disposeComponent();
        }
        return component;
    }

    public function setComponentIndex(child:Component, index:Int):Component {
        if (index >= 0 && index <= rootComponents.length) {
            handleSetComponentIndex(child, index);
            rootComponents.remove(child);
            rootComponents.insert(index, child);
        }
        return child;
    }

    public function moveComponentToFront(child:Component) {
        if (rootComponents.indexOf(child) != -1) {
            setComponentIndex(child, rootComponents.length - 1);
        }
    }
    
    public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
        var c:Array<Component> = [];
        for (r in rootComponents) {
            if (r.hitTest(screenX, screenY)) {
                var match = true;
                if (type != null && isOfType(r, type) == false) {
                    match = false;
                }
                if (match == true) {
                    c.push(r);
                }
            }
            c = c.concat(r.findComponentsUnderPoint(screenX, screenY, type));
        }
        return c;
    }
    
    public function hasComponentUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Bool {
        for (r in rootComponents) {
            if (r.hasComponentUnderPoint(screenX, screenY, type) == true) {
                return true;
            }
        }
        return false;
    }
    
    private function onThemeChanged() {
        for (c in rootComponents) {
            onThemeChangedChildren(c);
        }
    }

    @:access(haxe.ui.core.Component)
    private function onThemeChangedChildren(c:Component) {
        for (child in c.childComponents) {
            onThemeChangedChildren(child);
        }
        c.onThemeChanged();
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (supportsEvent(type) == true) {
            if (_eventMap.add(type, listener, priority) == true) {
                mapEvent(type, _onMappedEvent);
            }
        } else {
            #if debug
            trace('WARNING: Screen event "${type}" not supported');
            #end
        }
    }

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_eventMap.remove(type, listener) == true) {
            unmapEvent(type, _onMappedEvent);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        _eventMap.invoke(event.type, event);
    }
}

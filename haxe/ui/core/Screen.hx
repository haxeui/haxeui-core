package haxe.ui.core;

import haxe.ui.backend.ScreenImpl;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.events.UIEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.EventMap;

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

    public function new() {
        super();
        rootComponents = [];

        _eventMap = new EventMap();
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
        if (FocusManager.instance.hasView(component) == false) {
            FocusManager.instance.pushView(component);
        }
        if (component.hasEvent(UIEvent.RESIZE, _onRootComponentResize) == false) {
            component.registerEvent(UIEvent.RESIZE, _onRootComponentResize);
        }
        
        if (wasReady && component.hidden == false) {
            component.dispatch(new UIEvent(UIEvent.SHOWN));
        }
        
        return component;
    }

    public override function removeComponent(component:Component):Component {
        @:privateAccess component._hasScreen = false;
        super.removeComponent(component);
        component.depth = -1;
        rootComponents.remove(component);
        FocusManager.instance.removeView(component);
        component.unregisterEvent(UIEvent.RESIZE, _onRootComponentResize);
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

    public function findComponentsUnderPoint<T:Component>(screenX:Float, screenY:Float, type:Class<T> = null):Array<Component> {
        var c:Array<Component> = [];
        for (r in rootComponents) {
            c = c.concat(r.findComponentsUnderPoint(screenX, screenY, type));
        }
        return c;
    }
    
    public function messageBox(message:String, title:String = null, type:MessageBoxType = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        return Toolkit.messageBox(message, title, type, modal, callback);
    }

    public function dialog(contents:Component, title:String = null, buttons:DialogButton = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        return Toolkit.dialog(contents, title, buttons, modal, callback);
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

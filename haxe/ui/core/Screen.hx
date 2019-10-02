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
    public var rootComponents:Array<Component>;

    private var _eventMap:EventMap;

    public function new() {
        super();
        rootComponents = [];
        
        _eventMap = new EventMap();
    }

    public override function addComponent(component:Component) {
        super.addComponent(component);
        #if !haxeui_android
        component.ready();
        #end
        rootComponents.push(component);
        FocusManager.instance.pushView(component);
        component.registerEvent(UIEvent.RESIZE, _onRootComponentResize);    //refresh vh & vw
    }

    public override function removeComponent(component:Component) {
        super.removeComponent(component);
        component.depth = -1;
        rootComponents.remove(component);
        component.unregisterEvent(UIEvent.RESIZE, _onRootComponentResize);
    }

    public function setComponentIndex(child:Component, index:Int) {
        if (index >= 0 && index <= rootComponents.length) {
            handleSetComponentIndex(child, index);
            rootComponents.remove(child);
            rootComponents.insert(index, child);
        }
    }

    public function refreshStyleRootComponents() {
        for (component in rootComponents) {
            _refreshStyleComponent(component);
        }
    }

    @:access(haxe.ui.core.Component)
    private function _refreshStyleComponent(component:Component) {
        for (child in component.childComponents) {
//            child.applyStyle(child.style);
            child.invalidateComponentStyle();
            child.invalidateComponentDisplay();
            _refreshStyleComponent(child);
        }
    }

    private function _onRootComponentResize(e:UIEvent) {
        _refreshStyleComponent(e.target);
    }
    
    public function messageBox(message:String, title:String = null, type:MessageBoxType = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        return Toolkit.messageBox(message, title, type, modal, callback);
    }
  
    public function dialog(contents:Component, title:String = null, buttons:DialogButton = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        return Toolkit.dialog(contents, title, buttons, modal, callback);
    }
    
    private function invalidateAll() {
        for (c in rootComponents) {
            invalidateChildren(c);
        }
    }
    
    private function invalidateChildren(c:Component) {
        for (child in c.childComponents) {
            invalidateChildren(child);
        }
        c.invalidateComponent();
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

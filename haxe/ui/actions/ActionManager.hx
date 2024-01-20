package haxe.ui.actions;

import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.ActionEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.util.EventMap;
import haxe.ui.util.Timer;

typedef RepeatActionInfo = {
    var type:ActionType;
    var timer:Timer;
}

enum abstract NavigationMethod(String) from String to String {
    var DESKTOP:String = "navigationDesktop";
    var DPAD:String = "navigationDPad";
}

@:access(haxe.ui.core.InteractiveComponent)
class ActionManager {
    private static var _instance:ActionManager;
    public static var instance(get, null):ActionManager;
    private static function get_instance():ActionManager {
        if (_instance == null) {
            _instance = new ActionManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    public var navigationMethod:NavigationMethod = NavigationMethod.DESKTOP;
    
    private var _events:EventMap = null;
    private var _inputSources:Array<IActionInputSource> = [];
    private var _repeatActions:Map<ActionType, RepeatActionInfo> = new Map<ActionType, RepeatActionInfo>();
    
    public function new() {
    }
    
    public function registerEvent(type:String, listener:ActionEvent->Void, priority:Int = 0) {
        if (_events == null) {
            _events = new EventMap();
        }
        _events.add(type, listener, priority);
    }

    public function unregisterEvent(type:String, listener:ActionEvent->Void) {
        if (_events == null) {
            return;
        }
        _events.remove(type, listener);
    }
    
    public function dispatch(event:ActionEvent) {
        if (_events == null) {
            return;
        }
        _events.invoke(event.type, event);
    }
    
    public function registerInputSource(source:IActionInputSource) {
        source.start();
        _inputSources.push(source);
    }
    
    public function actionStart(action:ActionType, source:IActionInputSource) {
        var currentFocus = FocusManager.instance.focus;
        if (currentFocus == null) {
            // #if debug
            // trace("no focus for action: " + action);
            // #end
            return;
        }
        
        if (!(currentFocus is InteractiveComponent)) {
            // #if debug
            // trace("current focus not interactive: " + action);
            // #end
            return;
        }

        var actionEvent = new ActionEvent(ActionEvent.ACTION_START, action);
        var c = cast(currentFocus, InteractiveComponent);
        c.dispatch(actionEvent);
        if (actionEvent.canceled == false) {
            dispatch(new ActionEvent(ActionEvent.ACTION_START, action, false, Type.getClassName(Type.getClass(source))));
        }
        if (actionEvent.repeater == true) {
            if (_repeatActions.exists(action)) {
                var info = _repeatActions.get(action);
                info.timer.stop();
                _repeatActions.remove(action);
            }
            _repeatActions.set(action, {
                type: action,
                timer: new Timer(c.actionRepeatInterval, function() { // TODO: 100ms should probably be configurable
                    actionStart(action, source);
                })
            });
        }
    }
    
    public function actionEnd(action:ActionType, source:IActionInputSource) {
        var currentFocus = FocusManager.instance.focus;
        if (currentFocus == null) {
            return;
        }
        
        if (!(currentFocus is InteractiveComponent)) {
            // #if debug
            // trace("current focus not interactive: " + action);
            // #end
            return;
        }
        
        var actionEvent = new ActionEvent(ActionEvent.ACTION_END, action);
        var c = cast(currentFocus, InteractiveComponent);
        c.dispatch(actionEvent);
        if (actionEvent.canceled == false) {
            dispatch(new ActionEvent(ActionEvent.ACTION_END, action, false, Type.getClassName(Type.getClass(source))));
        }
        if (_repeatActions.exists(action)) {
            var info = _repeatActions.get(action);
            info.timer.stop();
            _repeatActions.remove(action);
        }
    }
}

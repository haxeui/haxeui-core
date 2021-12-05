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
    private var _events:EventMap = null;
    private var _inputSources:Array<IActionInputSource> = [];
    private var _repeatActions:Map<ActionType, RepeatActionInfo> = new Map<ActionType, RepeatActionInfo>();
    
    public function new() {
        registerInputSource(new KeyboardActionInputSource());
    }
    
    public function init() {
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
    
    public function actionStart(action:ActionType) {
        var currentFocus = FocusManager.instance.focus;
        if (currentFocus == null) {
            #if debug
            trace("no focus for action: " + action);
            #end
            return;
        }
        
        if (!(currentFocus is InteractiveComponent)) {
            #if debug
            trace("current focus not interactive: " + action);
            #end
            return;
        }

        var c = cast(currentFocus, InteractiveComponent);
        var repeat = c.actionStart(action);
        if (repeat == true && _repeatActions.exists(action) == false) {
            _repeatActions.set(action, {
                type: action,
                timer: new Timer(100, function() { // TODO: 100ms should probably be configurable
                    actionStart(action);
                })
            });
        }
    }
    
    public function actionEnd(action:ActionType) {
        var currentFocus = FocusManager.instance.focus;
        if (currentFocus == null) {
            return;
        }
        
        if (!(currentFocus is InteractiveComponent)) {
            trace("current focus not interactive: " + action);
            return;
        }
        
        var c = cast(currentFocus, InteractiveComponent);
        c.actionEnd(action);
        
        if (_repeatActions.exists(action)) {
            var info = _repeatActions.get(action);
            info.timer.stop();
            _repeatActions.remove(action);
        }
    }
}
package haxe.ui.actions;

import haxe.ui.actions.IActionInputSource;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.ActionEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.geom.Point;
import haxe.ui.util.EventMap;
import haxe.ui.util.Timer;

typedef RepeatActionInfo = {
    var type:ActionType;
    var timer:Timer;
}

@:enum
abstract NavigationMethod(String) from String to String {
    var DESKTOP:String = "navigationDesktop";
    var REMOTE:String = "navigationRemote";
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
    
    private var _activatedComponent:InteractiveComponent = null;
    public function actionStart(action:ActionType, source:IActionInputSource) {
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
        if (navigationMethod == NavigationMethod.REMOTE && _activatedComponent == null) {
            switch (action) {
                case ActionType.PRESS | ActionType.OK | ActionType.CONFIRM:
                    if (c.requiresActivation == true && c.activated == false) {
                        c.activated = true;
                        _activatedComponent = c;
                        return;
                    }
                case ActionType.UP:
                    var c = findComponent("north");
                    if (c != null) {
                        c.focus = true;
                    }
                    return;
                case ActionType.DOWN:
                    var c = findComponent("south");
                    if (c != null) {
                        c.focus = true;
                    }
                    return;
                case ActionType.RIGHT:
                    var c = findComponent("east");
                    if (c != null) {
                        c.focus = true;
                    }
                    return;
                case ActionType.LEFT:
                    var c = findComponent("west");
                    if (c != null) {
                        c.focus = true;
                    }
                    return;
                case _:    
            }
            /*
            if (c.requiresActivation == true && c.activated == false) {
                if (action == ActionType.PRESS || action == ActionType.OK) {
                    c.activated = true;
                }
                return;
            }
            */
        } else if (navigationMethod == NavigationMethod.REMOTE && _activatedComponent != null) {
            switch (action) {
                case ActionType.BACK:
                    _activatedComponent.activated = false;
                    _activatedComponent.addClass(":activatable");
                    _activatedComponent = null;
                    return;
                case _:    
            }
        }
        
        var actionEvent = new ActionEvent(ActionEvent.ACTION_START, action);
        var c = cast(currentFocus, InteractiveComponent);
        c.dispatch(actionEvent);
        dispatch(new ActionEvent(ActionEvent.ACTION_START, action, false, Type.getClassName(Type.getClass(source))));
        if (actionEvent.repeater == true  && _repeatActions.exists(action) == false) {
            _repeatActions.set(action, {
                type: action,
                timer: new Timer(100, function() { // TODO: 100ms should probably be configurable
                    actionStart(action, source);
                })
            });
        }
        /*
        var repeat = c.actionStart(action);
        if (repeat == true && _repeatActions.exists(action) == false) {
            _repeatActions.set(action, {
                type: action,
                timer: new Timer(100, function() { // TODO: 100ms should probably be configurable
                    actionStart(action, source);
                })
            });
        }
        */
    }
    
    public function actionEnd(action:ActionType, source:IActionInputSource) {
        var currentFocus = FocusManager.instance.focus;
        if (currentFocus == null) {
            return;
        }
        
        if (!(currentFocus is InteractiveComponent)) {
            #if debug
            trace("current focus not interactive: " + action);
            #end
            return;
        }
        
        var actionEvent = new ActionEvent(ActionEvent.ACTION_END, action);
        var c = cast(currentFocus, InteractiveComponent);
        c.dispatch(actionEvent);
        dispatch(new ActionEvent(ActionEvent.ACTION_END, action, false, Type.getClassName(Type.getClass(source))));
        if (_repeatActions.exists(action)) {
            var info = _repeatActions.get(action);
            info.timer.stop();
            _repeatActions.remove(action);
        }
        /*
        c.actionEnd(action);
        
        if (_repeatActions.exists(action)) {
            var info = _repeatActions.get(action);
            info.timer.stop();
            _repeatActions.remove(action);
        }
        */
    }
    
    public var rayStep:Int = 5;
    public function findComponent(direction:String, from:Component = null):InteractiveComponent {
        if (from == null) {
            from = cast FocusManager.instance.focus;
        }

        if (from == null) {
            #if debug
            trace("no from component");
            #end
            return null;
        }
        
        var c:InteractiveComponent = null;
        var pt:Point = new Point(from.screenLeft + (from.width / 2), from.screenTop + (from.height / 2));
        switch (direction) {
            case "north":
                pt.x = from.screenLeft;
                pt.y = from.screenTop;
            case "south":
                pt.x = from.screenLeft;
                pt.y = from.screenTop + from.height;
            case "east":
                pt.x = from.screenLeft + from.width;
                pt.y = from.screenTop;
            case "west":
                pt.x  = from.screenLeft;
                pt.y = from.screenTop;
        }
        
        /*
        while (c == null) {
            switch (direction) {
                case "north":
                    pt.y -= rayStep;
                case "south":
                    pt.y += rayStep;
                case "east":
                    pt.x += rayStep;
                case "west":
                    pt.x -= rayStep;
            }
            trace(pt);
            var list = Screen.instance.findComponentsUnderPoint(pt.x, pt.y, InteractiveComponent);
            trace(list.length);
            if (list.length > 0) {
                c = list[0];
            }
            for (l in list) {
                trace(l.className, l.text);
            }
            if (pt.x < 0 || pt.y < 0 || pt.x > Screen.instance.width || pt.y > Screen.instance.height) {
                break;
            }
        }
        */
        while (c == null) {
            switch (direction) {
                case "north":
                    pt.x = from.screenLeft;
                    pt.y -= rayStep;
                case "south":
                    pt.x = from.screenLeft;
                    pt.y += rayStep;
                case "east":                    
                    pt.x += rayStep;
                    pt.y = from.screenTop;
                case "west":    
                    pt.x -= rayStep;
                    pt.y = from.screenTop;
            }
            
            var n:Float = 0;
            var count = 0;
            switch (direction) {
                case "north" | "south":
                    n = from.width / rayStep;
                    count = Std.int(from.width / n);
                case "east" | "west":
                    n = from.height / rayStep;
                    count = Std.int(from.height / n);
            }
            
            for (i in 0...count + 1) {
                if (Screen.instance.hasComponentUnderPoint(pt.x, pt.y, InteractiveComponent) == true) {
                    var list = Screen.instance.findComponentsUnderPoint(pt.x, pt.y, InteractiveComponent);
                    c = cast(list[0], InteractiveComponent);
                    break;
                }
                
                switch (direction) {
                    case "north" | "south":
                        pt.x += n;
                    case "east" | "west":
                        pt.y += n;
                }
            }
            
            
            if (pt.x < 0 || pt.y < 0 || pt.x > Screen.instance.width || pt.y > Screen.instance.height) {
                break;
            }
        }
        
        return c;
    }
}
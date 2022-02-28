package haxe.ui.focus;

import haxe.ui.backend.FocusManagerImpl;
import haxe.ui.core.Component;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.focus.IFocusable;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

typedef FocusInfo = { // focus info for a given view (component)
    var view:Component;
    var currentFocus:IFocusable;
}

class FocusManager extends FocusManagerImpl {
    private static var _instance:FocusManager;
    public static var instance(get, null):FocusManager;
    private static function get_instance():FocusManager {
        if (_instance == null) {
            _instance = new FocusManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    public var autoFocus:Bool = true; // whether or not to automatically set focus to the first interactive component in a view when its added
    
    private var _applicators:Array<IFocusApplicator> = [];
    
    private var _viewStack:Array<FocusInfo> = [];

    public function new() {
        super();
        _applicators.push(new StyleFocusApplicator());
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function onScreenMouseDown(event:MouseEvent) {
        return;
        var list = Screen.instance.findComponentsUnderPoint(event.screenX, event.screenY);
        for (l in list) {
            if (isOfType(l, IFocusable)) {
                return;
            }
        }
        
        focus = null;
    }
    
    public function pushView(view:Component) {
        if (hasView(view) == false) {
            _viewStack.push({
                view: view,
                currentFocus: null
            });
            
            if (autoFocus == true) {
                var interactiveComponents = view.findComponents(InteractiveComponent, -1);
                if (interactiveComponents != null && interactiveComponents.length > 0) {
                    for (i in interactiveComponents) {
                        if (i.allowFocus == true) {
                            focus = i;
                            break;
                        }
                    }
                }
            }
        }
        
    }

    public function hasView(view:Component):Bool {
        for (info in _viewStack) {
            if (info.view == view) {
                return true;
            }
        }
        return false;
    }
    
    public function popView() {
        var info = _viewStack.pop();
        removeView(info.view);
    }

    public function removeView(view:Component) {
        for (info in _viewStack) {
            if (info.view == view) {
                _viewStack.remove(info);
                break;
            }
        }
    }

    public var focusInfo(get, null):FocusInfo;
    private function get_focusInfo():FocusInfo {
        if (_viewStack.length == 0) {
            return null;
        }
        
        var info = _viewStack[_viewStack.length - 1];
        return info;
    }

    public var focus(get, set):IFocusable;
    private function get_focus():IFocusable {
        if (focusInfo == null) {
            return null;
        }
        return focusInfo.currentFocus;
    }
    private function set_focus(value:IFocusable):IFocusable {
        if (value != null && (value is IFocusable) == false) {
            throw "Component does not implement IFocusable";
        }
        if (value != null && (value.allowFocus == false || value.disabled == true)) {
            return value;
        }

        if (focusInfo != null && focusInfo.currentFocus != null && focusInfo.currentFocus != value) {
            unapplyFocus(cast focusInfo.currentFocus);
            focusInfo.currentFocus = null;
        }
        if (value != null) {
            focusInfo.currentFocus = value;
            applyFocus(cast focusInfo.currentFocus);
        }

        if (focusInfo == null) {
            return value;
        }
        return focusInfo.currentFocus;
    }

    public function focusNext():Component {
        if (_viewStack.length == 0) {
            return null;
        }

        var list:Array<IFocusable> = [];
        var info = focusInfo;
        var currentFocus = buildFocusableList(info.view, list);

        var index = -1;
        if (currentFocus != null) {
            index = list.indexOf(currentFocus);
        }

        var nextIndex = index + 1;
        if (nextIndex > list.length - 1) {
            nextIndex = 0;
        }

        var nextFocus = list[nextIndex];
        focus = nextFocus;
        return cast nextFocus;
    }

    public function focusPrev():Component {
        if (_viewStack.length == 0) {
            return null;
        }

        var list:Array<IFocusable> = [];
        var info = focusInfo;
        var currentFocus = buildFocusableList(info.view, list);

        var index = -1;
        if (currentFocus != null) {
            index = list.indexOf(currentFocus);
        }

        var prevIndex = index - 1;
        if (prevIndex < 0) {
            prevIndex = list.length - 1;
        }

        var prevFocus = list[prevIndex];
        focus = prevFocus;
        return cast prevFocus;
    }

    private function buildFocusableList(c:Component, list:Array<IFocusable>):IFocusable {
        var currentFocus = null;
        if (c.hidden == true) {
            return null;
        }
        
        if ((c is IFocusable)) {
            var f:IFocusable = cast c;
            if (f.allowFocus == true && f.disabled == false) {
                if (f.focus == true) {
                    currentFocus = f;
                }
                list.push(f);
            }
        }

        var childList = c.childComponents;
        childList.sort(function(c1, c2) {
            return c1.componentTabIndex - c2.componentTabIndex;
        });
        
        for (child in childList) {
            var f:IFocusable = buildFocusableList(child, list);
            if (f != null) {
                currentFocus = f;
            }
        }
        return cast currentFocus;
    }
    
    private override function applyFocus(c:Component) {
        super.applyFocus(c);
        cast(c, IFocusable).focus = true;
        for (a in _applicators) {
            a.apply(c);
        }
    }
    
    private override function unapplyFocus(c:Component) {
        super.unapplyFocus(c);
        cast(c, IFocusable).focus = false;
        for (a in _applicators) {
            a.unapply(c);
        }
    }
}
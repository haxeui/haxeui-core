package haxe.ui.focus;

import haxe.ui.core.Component;

class FocusInfo {
    public function new() {

    }
    public var view:Component;
    public var currentFocus:IFocusable;
}

class FocusManager {
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
    private var _views:Array<Component>;
    private var _focusInfo:Map<Component, FocusInfo>;

    public function new() {
        _views = [];
        _focusInfo = new Map<Component, FocusInfo>();
    }

    public function pushView(component:Component) {
        _views.push(component);
    }

    public function popView() {
        var c = _views.pop();
        _focusInfo.remove(c);
    }

    public var focusInfo(get, null):FocusInfo;
    private function get_focusInfo():FocusInfo {
        if (_views.length == 0) {
            return null;
        }
        var c:Component = _views[_views.length - 1];
        var info = _focusInfo.get(c);
        if (info == null) {
            info = new FocusInfo();
            info.view = c;
            _focusInfo.set(c, info);
        }
        return info;
    }

    public var focus(get, set):IFocusable;
    private function get_focus():IFocusable {
        return focusInfo.currentFocus;
    }
    private function set_focus(value:IFocusable):IFocusable {
        if (Std.is(value, IFocusable) == false) {
            throw "Component does not implement IFocusable";
        }
        
        if (focusInfo == null) { // TODO: just a patch for now, this all needs reworking
            return value;
        }
        
        if (focusInfo.currentFocus != null && focusInfo.currentFocus != value) {
            focusInfo.currentFocus.focus = false;
            focusInfo.currentFocus = null;
        }
        if (value != null) {
            focusInfo.currentFocus = value;
            focusInfo.currentFocus.focus = true;
        }

        Toolkit.screen.focus = cast value;

        return focusInfo.currentFocus;
    }

    public function focusNext():Component {
        if (_views.length == 0) {
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
        if (_views.length == 0) {
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
        if (Std.is(c, IFocusable)) {
            var f:IFocusable = cast c;
            if (f.allowFocus == true) {
                if (f.focus == true) {
                    currentFocus = f;
                }
                list.push(f);
            }
        }

        for (child in c.childComponents) {
            var f:IFocusable = buildFocusableList(child, list);
            if (f != null) {
                currentFocus = f;
            }
        }
        return cast currentFocus;
    }
}
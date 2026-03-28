package haxe.ui.events;

import haxe.ui.actions.ActionType;
import haxe.ui.core.Component;

@:access(haxe.ui.core.Component)
class Events {
    private var _target:Component;

    public function new(target:Component) {
        _target = target;
    }

    public function register() {
    }

    public function unregister() {
    }

    public function onDispose() {
    }
    
    private function registerEvent<T:UIEvent>(type:EventType<T>, listener:T->Void, priority:Int = 0) {
        if (_target == null || _target._isDisposed) {
            return;
        }
        #if cpp
        // On hxcpp, function comparison is broken (cast closures falsely compare
        // as equal), so hasEvent would incorrectly block new listeners. Skip the
        // check and let EventMap.add handle it.
        _target.registerEvent(type, listener, priority);
        #else
        if (hasEvent(type, listener) == false) {
            _target.registerEvent(type, listener, priority);
        }
        #end
    }

    private function hasEvent<T:UIEvent>(type:EventType<T>, listener:T->Void):Bool {
        if (_target == null || _target._isDisposed) {
            return false;
        }
        return _target.hasEvent(type, listener);
    }

    private function registerEventOn<T:UIEvent>(child:Component, type:EventType<T>, listener:T->Void, priority:Int = 0) {
        if (child == null || child._isDisposed) {
            return;
        }
        #if cpp
        child.registerEvent(type, listener, priority);
        #else
        if (child.hasEvent(type, listener) == false) {
            child.registerEvent(type, listener, priority);
        }
        #end
    }

    private function unregisterEvent<T:UIEvent>(type:EventType<T>, listener:T->Void) {
        if (_target == null || _target._isDisposed) {
            return;
        }
        _target.unregisterEvent(type, listener);
    }

    private function dispatch<T:UIEvent>(event:T) {
        if (_target == null || _target._isDisposed) {
            return;
        }
        _target.dispatch(event);
    }
}
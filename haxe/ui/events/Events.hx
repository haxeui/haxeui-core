package haxe.ui.events;

import haxe.ui.actions.ActionType;
import haxe.ui.core.Component;

@:access(haxe.ui.core.Component)
class Events {
    private var _target:Component;

    #if cpp
    // On hxcpp, function comparison is broken (cast closures falsely compare
    // as equal), so we cannot use hasEvent/contains for deduplication.
    // Instead, we track registered call sites using PosInfos (file + line)
    // which the compiler fills in automatically at each call site.
    private var _cppRegisteredKeys:Map<String, Bool> = new Map<String, Bool>();
    #end

    public function new(target:Component) {
        _target = target;
    }

    public function register() {
    }

    public function unregister() {
        #if cpp
        _cppRegisteredKeys = new Map<String, Bool>();
        #end
    }

    public function onDispose() {
    }

    private function registerEvent<T:UIEvent>(type:EventType<T>, listener:T->Void, priority:Int = 0, ?pos:haxe.PosInfos) {
        if (_target == null || _target._isDisposed) {
            return;
        }
        #if cpp
        var key = '${pos.lineNumber}:${pos.fileName}:${type}';
        if (_cppRegisteredKeys.exists(key)) {
            return;
        }
        _cppRegisteredKeys.set(key, true);
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
        #if cpp
        return false;
        #else
        return _target.hasEvent(type, listener);
        #end
    }

    private function registerEventOn<T:UIEvent>(child:Component, type:EventType<T>, listener:T->Void, priority:Int = 0, ?pos:haxe.PosInfos) {
        if (child == null || child._isDisposed) {
            return;
        }
        #if cpp
        var key = '${pos.lineNumber}:${pos.fileName}:${type}';
        if (_cppRegisteredKeys.exists(key)) {
            return;
        }
        _cppRegisteredKeys.set(key, true);
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

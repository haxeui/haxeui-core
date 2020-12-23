package haxe.ui.events;

import haxe.ui.core.Component;

class Events {
    private var _target:Component;

    public function new(target:Component) {
        _target = target;
    }

    public function register() {

    }

    public function unregister() {

    }

    private function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (hasEvent(type, listener) == false) {
            _target.registerEvent(type, listener, priority);
        }
    }

    private function hasEvent(type:String, listener:Dynamic->Void):Bool {
        return _target.hasEvent(type, listener);
    }

    private function unregisterEvent(type:String, listener:Dynamic->Void) {
        _target.unregisterEvent(type, listener);
    }

    private function dispatch(event:UIEvent) {
        _target.dispatch(event);
    }
}
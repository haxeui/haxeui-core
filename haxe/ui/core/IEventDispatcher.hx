package haxe.ui.core;

import haxe.ui.events.UIEvent;

interface IEventDispatcher<T:UIEvent> {
    public function registerEvent<T:UIEvent>(type:String, listener:T->Void, priority:Int = 0):Void;
    public function hasEvent<T:UIEvent>(type:String, listener:T->Void = null):Bool;
    public function unregisterEvent<T:UIEvent>(type:String, listener:T->Void):Void;
    public function dispatch<T:UIEvent>(event:T, target:Component = null):Void;
    public function removeAllListeners():Void;
}
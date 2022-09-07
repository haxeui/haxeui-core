package haxe.ui.backend;

import haxe.ui.Preloader.PreloadItem;
import haxe.ui.events.UIEvent;
import haxe.ui.util.EventMap;

class AppBase {
    private var __events:EventMap = null;

    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (__events == null) {
            __events = new EventMap();
        }
        __events.add(type, listener, priority);
    }

    public function hasEvent(type:String, listener:Dynamic->Void = null):Bool {
        if (__events == null) {
            return false;
        }
        return __events.contains(type, listener);
    }

    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (__events != null) {
            __events.remove(type, listener);
        }
    }

    public function dispatch(event:UIEvent) {
        if (__events != null) {
            __events.invoke(event.type, event, null);
        }
    }

    private function build() {
    }

    private function init(onReady:Void->Void, onEnd:Void->Void = null) {
        onReady();
    }

    private function getToolkitInit():ToolkitOptions {
        return {};
    }

    public function start() {
    }

    public function exit() {
    }

    private function buildPreloadList():Array<PreloadItem> {
        return [];
    }

    private var _icon:String = null;
    public var icon(get, set):String;
    private function get_icon():String {
        return _icon;
    }
    private function set_icon(value:String):String {
        _icon = value;
        return value;
    }
}
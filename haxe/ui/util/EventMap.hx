package haxe.ui.util;

import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;

class EventMap  {
    private var _map:Map<String, FunctionArray<UIEvent->Void>>;

    public function new() {
        _map = new Map<String, FunctionArray<UIEvent->Void>>();
    }

    public function keys():Iterator<String> {
        return _map.keys();
    }
    
    public function add(type:String,  listener:UIEvent->Void):Bool { // returns true if a new FunctionArray was created
        var b:Bool = false;
        var arr:FunctionArray<UIEvent->Void> = _map.get(type);
        if (arr == null) {
            arr = new FunctionArray<UIEvent->Void>();
            arr.push(listener);
            _map.set(type, arr);
            b = true;
        } else if (arr.contains(listener) == false) {
            arr.push(listener);
        }
        return b;
    }

    public function remove(type:String, listener:UIEvent->Void):Bool { // returns true if a FunctionArray was removed
        var b:Bool = false;
        var arr:FunctionArray<UIEvent->Void> = _map.get(type);
        if (arr != null) {
            arr.remove(listener);
            if (arr.length == 0) {
                _map.remove(type);
                b = true;
            }
        }
        return b;
    }

    public function invoke(type:String, event:UIEvent, target:Component = null) {
        var arr:FunctionArray<UIEvent->Void> = _map.get(type);
        if (arr != null) {
            arr = arr.copy();
            for (fn in arr) {
                var c = event.clone();
                c.target = target;
                fn(c);
            }
        }
    }

    public function listenerCount(type:String):Int {
        var n:Int = 0;
        var arr:FunctionArray<UIEvent->Void> = _map.get(type);
        if (arr != null) {
            n = arr.length;
        }
        return n;
    }
    
    public function listeners(type:String):FunctionArray<UIEvent->Void> {
        var arr:FunctionArray<UIEvent->Void> = _map.get(type);
        if (arr == null) {
            return null;
        }
        return arr;
    }
}
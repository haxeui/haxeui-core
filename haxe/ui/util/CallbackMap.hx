package haxe.ui.util;

class CallbackMap<T> {
    private var _map:Map<String, FunctionArray<T->Void>>;

    public function new() {
        _map = new Map<String, FunctionArray<T->Void>>();
    }

    public function add(key:String, callback:T->Void):Bool { // returns true if a new FunctionArray was created
        if (callback == null) {
            return false;
        }
        var b:Bool = false;
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr == null) {
            arr = new FunctionArray<T->Void>();
            arr.push(callback);
            _map.set(key, arr);
            b = true;
        } else if (arr.contains(callback) == false) {
            arr.push(callback);
        }
        return b;
    }

    public function remove(key:String,  callback:T->Void):Bool { // returns true if a FunctionArray was removed
        var b:Bool = false;
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr != null) {
            arr.remove(callback);
            if (arr.length == 0) {
                _map.remove(key);
                b = true;
            }
        }
        return b;
    }

    public function removeAll(key:String) {
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr != null) {
            while (arr.length > 0) {
                arr.remove(arr.get(0));
            }
            _map.remove(key);
        }
    }

    public function invoke(key:String, param:T) {
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr != null) {
            arr = arr.copy();
            for (fn in arr) {
                fn(param);
            }
        }
    }

    public function invokeAndRemove(key:String, param:T) {
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr != null) {
            arr = arr.copy();
            removeAll(key);
            for (fn in arr) {
                fn(param);
            }
        }
    }

    public function count(key:String):Int {
        var n:Int = 0;
        var arr:FunctionArray<T->Void> = _map.get(key);
        if (arr != null) {
            n = arr.length;
        }
        return n;
    }
}
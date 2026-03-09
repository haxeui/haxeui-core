package haxe.ui.util;

class FunctionArray<T> {
    private var _array:Array<Listener<T>>;

    public function new() {
        _array = [];
    }

    public function get(index:Int):T {
        return _array[index].callback;
    }

    public var length(get, null):Int;
    private function get_length():Int {
        return _array.length;
    }

    public function push(x:T, priority:Int = 0, ?originalRef:Dynamic):Int {
        var listener:Listener<T> = new Listener(x, priority);
        listener.originalRef = originalRef;
        for (i in 0..._array.length) {
            if (_array[i].priority < priority) {
                _array.insert(i, listener);
                return i;
            }
        }

        return _array.push(listener);
    }

    public function pop():Null<T> {
        return _array.pop().callback;
    }

    public function indexOf(x:T, fromIndex:Int = 0, ?originalRef:Dynamic):Int {
        for (i in fromIndex..._array.length) {
            if (_array[i].callback == x || Reflect.compareMethods(_array[i].callback, x)) {
                return i;
            }
            if (originalRef != null && _array[i].originalRef != null) {
                if (_array[i].originalRef == originalRef || Reflect.compareMethods(_array[i].originalRef, originalRef)) {
                    return i;
                }
            }
        }
        return -1;
    }

    public function remove(x:T, ?originalRef:Dynamic):Bool {
        var index:Int = indexOf(x, 0, originalRef);
        if (index != -1) {
            _array.splice(index, 1);
        }

        return index != -1;
    }

    public function contains(x:T, ?originalRef:Dynamic):Bool {
        return indexOf(x, 0, originalRef) != -1;
    }

    public function iterator():Iterator<Listener<T>> {
        return _array.iterator();
    }

    public function copy():FunctionArray<T> {
        var fa = new FunctionArray<T>();
        fa._array = _array.copy();
        return fa;
    }

    public function toString():String {
        var s:String = "[";
        var iter = this.iterator();
        while (iter.hasNext()) {
            s += Std.string(iter.next());
            if (iter.hasNext()) {
                s += ", ";
            }
        }
        s += "]";
        return s;
    }

    public function removeAll() {
        _array = [];
    }
}
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

    public function push(x:T, priority:Int = 0):Int {
        var listener:Listener<T> = new Listener(x, priority);
        for(i in 0..._array.length) {
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

    public function indexOf(x:T, fromIndex:Int = 0):Int {
        #if neko
        if (Reflect.isFunction(x) == false) {
            return _array.indexOf(cast x);
        } else {
            for (i in fromIndex..._array.length) {
                if (Reflect.compareMethods(_array[i].callback, x) == true) {
                    return i;
                }
            }
            return -1;
        }
        #else
        for (i in fromIndex..._array.length) {
            if (_array[i].callback == x) {
                return i;
            }
        }
        return -1;
        #end
    }

    public function remove(x:T):Bool {
        var index:Int = indexOf(x);
        if (index != -1) {
            _array.splice(index, 1);
        }

        return index != -1;
    }

    public function contains(x:T):Bool {
        return indexOf(x) != -1;
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

}
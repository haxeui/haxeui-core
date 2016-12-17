package haxe.ui.util;

class FunctionArray<T> {
    private var _array:Array<T>;

    public function new(array:Array<T> = null) {
        if (array == null) {
            _array = [];
        } else {
            _array = array;
        }
    }

    public function get(index:Int):T {
        return _array[index];
    }

    public var length(get, null):Int;
    private function get_length():Int {
        return _array.length;
    }

    public function push(x:T):Int {
        return _array.push(x);
    }

    public function pop():Null<T> {
        return _array.pop();
    }

    public function indexOf(x:T, fromIndex:Int = 0):Int {
        #if neko
        if (Reflect.isFunction(x) == false) {
            return _array.indexOf(x);
        } else {
            var index:Int = -1;
            var n:Int = 0;
            for (t in _array) {
                if (Reflect.compareMethods(t, x) == true) {
                    index = n;
                    break;
                }
                n++;
            }
            return index;
        }
        #else
        return _array.indexOf(x, fromIndex);
        #end
    }

    public function remove(x:T):Bool {
        #if neko
        var b = false;
        if (Reflect.isFunction(x) == false) {
            b = _array.remove(x);
        } else {
            var index = indexOf(x);
            if (index != -1) {
                _array.splice(index, 1);
                b = true;
            }
        }
        return b;
        #else
        return _array.remove(x);
        #end
    }

    public function contains(x:T):Bool {
        return indexOf(x) != -1;
    }

    public function iterator():Iterator<T> {
        return _array.iterator();
    }

    public function copy():FunctionArray<T> {
        return new FunctionArray<T>(_array.copy());
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
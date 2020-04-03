package haxe.ui.data;

import haxe.ui.data.transformation.IItemTransformer;

class ListDataSource<T> extends DataSource<T> {
   private var _array:List<T>;

    public function new(transformer:IItemTransformer<T> = null) {
        super(transformer);
        _array = new List<T>();
    }

    // overrides
    private override function handleGetSize():Int {
        return _array.length;
    }

    private override function handleGetItem(index:Int):T {
        var i = 0;
        var r = null;
        for (x in _array) {
            if (i == index) {
                r = x;
                break;
            }
            i++;
        }
        return r;
    }

    private override function handleIndexOf(item:T):Int {
        var i = 0;
        var r = null;
        var index = -1;
        for (x in _array) {
            if (x == item) {
                index = i;
                break;
            }
            i++;
        }
        return index;
    }

    private override function handleAddItem(item:T):T {
        _array.add(item);
        return item;
    }

    private override function handleInsert(index:Int, item:T):T {
        var i = 0;
        var r = null;
        for (x in _array) {
            if (i == index) {
                r = x;
                _array.push(item);
                break;
            }
            i++;
        }
        return r;
        
        return item;
    }

    private override function handleRemoveItem(item:T):T {
        _array.remove(item);
        return item;
    }

    private override function handleClear() {
        _array.clear();
    }

    private override function handleUpdateItem(index:Int, item:T):T {
        var i = 0;
        var r = null;
        for (x in _array) {
            if (i == index) {
                x = item;
                break;
            }
            i++;
        }
        return item;
    }

    public override function clone():DataSource<T> {
        var c:ListDataSource<T> = new ListDataSource<T>();
        c._array = Lambda.list(_array); // this is a shallow copy
        return c;
    }
    
    public static function fromArray<T>(source:Array<T>, transformer:IItemTransformer<T> = null):ListDataSource<T> {
        var ds = new ListDataSource<T>(transformer);
        for (i in source) {
            ds._array.add(i);
        }
        return ds;
    }
}

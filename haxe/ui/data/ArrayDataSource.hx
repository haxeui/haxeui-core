package haxe.ui.data;

import haxe.ui.data.transformation.IItemTransformer;

class ArrayDataSource<T> extends DataSource<T> {
    private var _array:Array<T>;

    public function new(transformer:IItemTransformer<T> = null) {
        super(transformer);
        _array = [];
    }

    // overrides
    private override function handleGetSize():Int {
        return _array.length;
    }

    private override function handleGetItem(index:Int):T {
        return _array[index];
    }

    private override function handleIndexOf(item:T):Int {
        return _array.indexOf(item);
    }

    private override function handleAddItem(item:T):T {
        _array.push(item);
        return item;
    }

    private override function handleInsert(index:Int, item:T):T {
        _array.insert(index, item);
        return item;
    }

    private override function handleRemoveItem(item:T):T {
        _array.remove(item);
        return item;
    }
    
    private override function handleClear() {
        while (_array.length > 0) {
            _array.pop();
        }
    }

    private override function handleGetData():Any {
        return _array;
    }
    
    private override function handleSetData(v:Any) {
        _array = v;
    }
    
    private override function handleUpdateItem(index:Int, item:T):T {
        return _array[index] = item;
    }

    public override function clone():DataSource<T> {
        var c:ArrayDataSource<T> = new ArrayDataSource<T>();
        c._array = _array.copy(); // this is a shallow copy
        return c;
    }

    public static function fromArray<T>(source:Array<T>, transformer:IItemTransformer<T> = null):ArrayDataSource<T> {
        var ds = new ArrayDataSource<T>(transformer);
        ds._array = source;
        return ds;
    }

}

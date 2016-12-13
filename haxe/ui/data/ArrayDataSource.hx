package haxe.ui.data;

import haxe.ui.data.transformation.IItemTransformer;

class ArrayDataSource<T> extends DataSource<T> {
    private var _array:Array<T> = new Array<T>();

    public function new(transformer:IItemTransformer<T> = null) {
        super(transformer);
    }

    // overrides
    private override function handleGetSize():Int {
        return _array.length;
    }

    private override function handleGetItem(index:Int):T {
        return _array[index];
    }

    private override function handleAddItem(item:T):T {
        _array.push(item);
        return item;
    }

    private override function handleRemoveItem(item:T):T {
        _array.remove(item);
        return item;
    }

    private override function handleUpdateItem(index:Int, item:T):T {
        return _array[index] = item;
    }

    public override function clone():DataSource<T> {
        var c:ArrayDataSource<T> = new ArrayDataSource<T>();
        c._array = _array.copy(); // this is a shallow copy
        return c;
    }

}
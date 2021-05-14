package haxe.ui.data;

import haxe.ui.data.transformation.IItemTransformer;

class ArrayDataSource<T> extends DataSource<T> {
    private var _array:Array<T>;

    public function new(transformer:IItemTransformer<T> = null) {
        super(transformer);
        _array = [];
    }

    // overrides
    private var _filteredArray:Array<T> = null;
    public override function clearFilter() {
        _filterFn = null;
        _filteredArray = null;
        handleChanged();
    }
    
    private var _filterFn:Int->T->Bool = null;
    public override function filter(fn:Int->T->Bool) {
        _filterFn = fn;
        _filteredArray = [];
        var index = 0;
        for (item in _array) {
            if (fn(index, item) == true) {
                _filteredArray.push(item);
            }
            index++;
        }
        handleChanged();
    }
    
    private override function handleGetSize():Int {
        if (_filteredArray != null) {
            return _filteredArray.length;
        }
        return _array.length;
    }

    private override function handleGetItem(index:Int):T {
        if (_filteredArray != null) {
            return _filteredArray[index];
        }
        return _array[index];
    }

    private override function handleIndexOf(item:T):Int {
        if (_filteredArray != null) {
            return _filteredArray.indexOf(item);
        }
        return _array.indexOf(item);
    }

    private override function handleAddItem(item:T):T {
        _array.push(item);
        if (_filteredArray != null && _filterFn != null) {
            if (_filterFn(_array.length - 1, item) == true) {
                _filteredArray.push(item);
            }
        }
        return item;
    }

    private override function handleInsert(index:Int, item:T):T {
        _array.insert(index, item);
        if (_filteredArray != null && _filterFn != null) {
            if (_filterFn(index, item) == true) {
                _filteredArray.push(item);
            }
        }
        return item;
    }

    private override function handleRemoveItem(item:T):T {
        _array.remove(item);
        if (_filteredArray != null) {
            _filteredArray.remove(item);
        }
        return item;
    }
    
    private override function handleClear() {
        while (_array.length > 0) {
            _array.pop();
        }
        if (_filteredArray != null) {
            while (_filteredArray.length > 0) {
                _filteredArray.pop();
            }
        }
    }

    private override function handleGetData():Any {
        if (_filteredArray != null) {
            return _filteredArray;
        }
        return _array;
    }
    
    private override function handleSetData(v:Any) {
        _array = v;
        if (_filterFn != null) {
            filter(_filterFn);
        }
    }
    
    private override function handleUpdateItem(index:Int, item:T):T {
        if (_filteredArray != null) {
            return _filteredArray[index] = item;
        }
        return _array[index] = item;
    }

    public override function clone():DataSource<T> {
        var c:ArrayDataSource<T> = new ArrayDataSource<T>();
        c._array = _array.copy(); // this is a shallow copy
        if (_filteredArray != null) {
            c._filteredArray = _filteredArray.copy();
        }
        if (_filterFn != null) {
            c._filterFn = _filterFn;
        }
        return c;
    }

    public static function fromArray<T>(source:Array<T>, transformer:IItemTransformer<T> = null):ArrayDataSource<T> {
        var ds = new ArrayDataSource<T>(transformer);
        ds._array = source;
        return ds;
    }

}

package haxe.ui.data;

import haxe.ui.data.transformation.IItemTransformer;

class DataSource<T> {
    public var onChange:Void->Void;
    public var transformer:IItemTransformer<T>;

    private var _changed:Bool;

    public var onAdd:T->Void = null;
    public var onInsert:Int->T->Void = null;
    public var onUpdate:Int->T->Void = null;
    public var onRemove:T->Void = null;
    public var onClear:Void->Void = null;
    
    public function new(transformer:IItemTransformer<T> = null) {
        this.transformer = transformer;
        _allowCallbacks = true;
        _changed = false;
    }

    private var _allowCallbacks:Bool;
    public var allowCallbacks(get, set):Bool;
    private function get_allowCallbacks():Bool {
        return _allowCallbacks;
    }
    private function set_allowCallbacks(value:Bool):Bool {
        _allowCallbacks = value;
        if (_allowCallbacks == true && _changed == true) {
            _changed = false;
            if (onChange != null) {
                onChange();
            }
        }
        return value;
    }

    public var size(get, null):Int;
    private function get_size():Int {
        return handleGetSize();
    }

    public function get(index:Int):T {
        var r:T = handleGetItem(index);
        if (Std.is(r, IDataItem)) {
            cast(r, IDataItem).onDataSourceChanged = onChange;
        }
        if (transformer != null) {
            r = transformer.transformFrom(r);
        }
        return r;
    }

    public function indexOf(item:T):Int {
        if(transformer != null) {
            item = transformer.transformFrom(item);
        }

        return handleIndexOf(item);
    }

    public function add(item:T):T {
        var r = handleAddItem(item);
        handleChanged();
        if (_allowCallbacks == true && onAdd != null) {
            onAdd(r);
        }
        return r;
    }

    public function insert(index:Int, item:T):T {
        var r = handleInsert(index, item);
        handleChanged();
        if (_allowCallbacks == true && onInsert != null) {
            onInsert(index, r);
        }
        return r;
    }

    public function remove(item:T):T {
        var r = handleRemoveItem(item);
        handleChanged();
        if (_allowCallbacks == true && onRemove != null) {
            onRemove(r);
        }
        return r;
    }

    public function update(index:Int, item:T):T {
        var r = handleUpdateItem(index, item);
        handleChanged();
        if (_allowCallbacks == true && onUpdate != null) {
            onUpdate(index, r);
        }
        return r;
    }

    public function clear() {
        var o = _allowCallbacks;
        _allowCallbacks = false;
        handleClear();
        _allowCallbacks = o;
        handleChanged();
        if (_allowCallbacks == true && onClear != null) {
            onClear();
        }
    }
    
    private function handleChanged() {
        _changed = true;
        if (_allowCallbacks == true && onChange != null) {
            _changed = false;
            onChange();
        }
    }

    // overrides
    private function handleGetSize():Int {
        return 0;
    }

    private function handleGetItem(index:Int):T {
        return null;
    }

    private function handleIndexOf(item:T):Int {
        return 0;
    }

    private function handleAddItem(item:T):T {
        return null;
    }

    private function handleInsert(index:Int, item:T):T {
        return null;
    }

    private function handleRemoveItem(item:T):T {
        return null;
    }

    private function handleClear() {
        var cachedTransformer = transformer;
        transformer = null;
        while (size > 0) {
            remove(get(0));
        }
        transformer = cachedTransformer;
    }

    private function handleUpdateItem(index:Int, item:T):T {
        return null;
    }

    public function clone():DataSource<T> {
        var c:DataSource<T> = new DataSource<T>();
        return c;
    }

    // helpers
    public static function fromString<T>(data:String, type:Class<DataSource<T>>):DataSource<T> {
        return null;
    }
}

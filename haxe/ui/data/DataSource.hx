package haxe.ui.data;

import haxe.ui.constants.SortDirection;
import haxe.ui.data.transformation.IItemTransformer;

class DataSource<T> {
    @:noCompletion
    public var onDataSourceChange:Void->Void;
    public var transformer:IItemTransformer<T>;

    private var _changed:Bool;

    public var onAdd:T->Void = null;
    public var onInsert:Int->T->Void = null;
    public var onUpdate:Int->T->Void = null;
    public var onRemove:T->Void = null;
    public var onClear:Void->Void = null;
    public var onChange:Void->Void = null;

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
            onInternalChange();
        }
        return value;
    }

    public var data(get, set):Any;
    private function get_data():Any {
        return handleGetData();
    }
    private function set_data(value:Any):Any {
        handleSetData(value);
        handleChanged();
        return value;
    }
    
    public var size(get, null):Int;
    private function get_size():Int {
        return handleGetSize();
    }

    public function get(index:Int):T {
        var r:T = handleGetItem(index);
        if ((r is IDataItem)) {
            cast(r, IDataItem).onDataSourceChanged = onDataItemChange;
        }
        if (transformer != null) {
            r = transformer.transformFrom(r);
        }
        return r;
    }

    public function indexOf(item:T):Int {
        if (transformer != null) {
            item = transformer.transformFrom(item);
        }

        return handleIndexOf(item);
    }

    public function add(item:T):Int {
        var index = handleAddItem(item);
        handleChanged();
        if (_allowCallbacks == true && onAdd != null) {
            onAdd(item);
        }
        return index;
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

    public function removeAt(index:Int):T {
        var item = get(index);
        return remove(item);
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

    private var _filterFn:Int->T->Bool = null;
    public function clearFilter() {
        _filterFn = null;
        handleClearFilter();
    }
    
    // callback (fn) should return true if the element should not be filtered out
    public function filter(fn:Int->T->Bool) {
        _filterFn = fn;
        handleFilter(fn);
    }
    
    public var isFiltered(get, null):Bool;
    private function get_isFiltered():Bool {
        return (_filterFn != null);
    }
    
    private function handleClearFilter() {
    }
    
    private function handleFilter(fn:Int->T->Bool) {
    }
    
    private function handleChanged() {
        _changed = true;
        if (_allowCallbacks == true) {
            _changed = false;
            onInternalChange();
        }
    }

    public function sortCustom(fn:T->T->SortDirection->Int, direction:SortDirection = null) {
    }
    
    public function sort(field:String = null, direction:SortDirection = null) {
        sortCustom(sortByFn.bind(_, _, _, field), direction);
    }
    
    private static var regexAlpha = new EReg("[^a-zA-Z]", "g");
    private static var regexNumeric = new EReg("[^0-9]", "g");
    private function sortByFn(o1:T, o2:T, direction:SortDirection, field:String):Int {
        var f1:Dynamic = o1;
        var f2:Dynamic = o2;

        if (field != null) {
            f1 = Reflect.field(o1, field);
            f2 = Reflect.field(o2, field);
        }

        if (f1 == null || f2 == null) {
            return 0;
        }

        f1 = Std.string(f1);
        f2 = Std.string(f2);

        if (direction == null) {
            direction = SortDirection.ASCENDING;
        }

        var high = 1;
        var low = -1;
        if (direction == SortDirection.DESCENDING) {
            high = -1;
            low = 1;
        }

        var alpha1 = regexAlpha.replace(f1, "");
        var alpha2 = regexAlpha.replace(f2, "");
        if (alpha1 == alpha2) {
            var numeric1 = Std.parseInt(regexNumeric.replace(f1, ""));
            var numeric2 = Std.parseInt(regexNumeric.replace(f2, ""));
            return numeric1 == numeric2 ? 0 : numeric1 > numeric2 ? high : low;
        }

        return alpha1 > alpha2 ? high : low;
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

    private function handleAddItem(item:T):Int {
        return -1;
    }

    private function handleInsert(index:Int, item:T):T {
        return null;
    }

    private function handleRemoveItem(item:T):T {
        return null;
    }

    private function handleGetData():Any {
        return null;
    }
    
    private function handleSetData(v:Any) {
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

    private function onDataItemChange() {
        if (_filterFn != null) {
            handleFilter(_filterFn);
        } else {
            onInternalChange();
        }
    }
    
    private function onInternalChange() {
        if (onDataSourceChange != null) {
            onDataSourceChange();
        }
        if (onChange != null) {
            onChange();
        }
    }
    
    // helpers
    public static function fromString<T>(data:String, type:Class<DataSource<T>>):DataSource<T> {
        return null;
    }
}

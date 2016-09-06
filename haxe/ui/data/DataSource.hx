package haxe.ui.data;
import haxe.ui.data.transformation.IItemTransformer;

class DataSource<T> {
    public var onChange:Void->Void;
    public var transformer:IItemTransformer<T>;
    
    public function new(transformer:IItemTransformer<T> = null) {
        this.transformer = transformer;
    }
    
    public var size(get, null):Int;
    private function get_size():Int {
        return handleGetSize();
    }
    
    public function get(index:Int):T {
        var r = handleGetItem(index);
        if (transformer != null) {
            r = transformer.transformFrom(r);
        }
        return r;
    }
    
    public function add(item:T):T {
        var r = handleAddItem(item);
        if (onChange != null) {
            onChange();
        }
        return r;
    }
    
    public function remove(item:T):T {
        var r = handleRemoveItem(item);
        if (onChange != null) {
            onChange();
        }
        return r;
    }
    
    public function update(index:Int, item:T):T {
        var r = handleUpdateItem(index, item);
        if (onChange != null) {
            onChange();
        }
        return r;
    }
    
    // overrides
    private function handleGetSize():Int {
        return 0;
    }
    
    private function handleGetItem(index:Int):T {
        return null;
    }
    
    private function handleAddItem(item:T):T {
        return null;
    }
    
    private function handleRemoveItem(item:T):T {
        return null;
    }
    
    private function handleUpdateItem(index:Int, item:T):T {
        return null;
    }
    
    // helpers
    public static function fromString<T>(data:String, type:Class<DataSource<T>>):DataSource<T> {
        return null;
    }
}
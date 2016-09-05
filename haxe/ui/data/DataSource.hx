package haxe.ui.data;

class DataSource<T> {
    public function new() {
        
    }
    
    public var onChange:Void->Void;
    
    public var size(get, null):Int;
    private function get_size():Int {
        return handleGetSize();
    }
    
    public function get(index:Int):T {
        return handleGetItem(index);
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
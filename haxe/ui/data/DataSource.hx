package haxe.ui.data;

class DataSource<T> {
    public function new() {
        
    }
    
    public var size(get, null):Int;
    private function get_size():Int {
        return handleGetSize();
    }
    
    public function get(index:Int):T {
        return handleGetItem(index);
    }
    
    public function add(item:T):T {
        return handleAddItem(item);
    }
    
    public function remove(item:T):T {
        return handleRemoveItem(item);
    }
    
    public function update(index:Int, item:T):T {
        return handleUpdateItem(index, item);
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
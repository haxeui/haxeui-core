package haxe.ui.styles;
import haxe.ui.util.Variant;

class StyleLookupMap {
    private static var _instance:StyleLookupMap;
    public static var instance(get, null):StyleLookupMap;
    private static function get_instance():StyleLookupMap {
        if (_instance == null) {
            _instance = new StyleLookupMap();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private var _valueMap:Map<String, Variant> = new Map<String, Variant>();
    
    private function new() {
    }
    
    public function set(name:String, value:Variant) {
        _valueMap.set(name, value);
    }
    
    public function get(name:String):Variant {
        return _valueMap.get(name);
    }
    
    public function remove(name:String) {
        _valueMap.remove(name);
    }
}
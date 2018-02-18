package descriptors;

class Descriptor {
    public function new() {
    }

    public var main(get, null):String;
    private function get_main():String {
        return null;
    }
    
    public function find(path:String):Bool {
        return false;
    }
}
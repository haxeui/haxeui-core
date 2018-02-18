package descriptors;
import sys.FileSystem;
import sys.io.File;

class KhaFile extends Descriptor {
    private var _path = null;
    
    private var _contents:String;
    
    public function new() {
        super();
    }

    private static inline var MAIN:String = "new Project('";
    private override function get_main():String {
        var n1 = _contents.indexOf(MAIN) + MAIN.length; // bit hacky
        var n2 = _contents.indexOf("'", n1);
        return _contents.substring(n1, n2);
    }
    
    public function load(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        _contents = File.getContent(path);
        _path = path;
    }
    
    public override function find(path:String):Bool {
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            if (FileSystem.isDirectory(path + "/" + c) == false && c == "khafile.js") {
                load(path + "/" + c);
                return true;
            }
        }
        return false;
    }
}
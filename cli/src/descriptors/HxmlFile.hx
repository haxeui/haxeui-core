package descriptors;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class HxmlFile extends Descriptor {
    private var _path = null;
    
    private var _lines:Array<String>;
    
    public function new() {
        super();
    }
    
    public function changeOutput(path) {
        var i = 0;
        for (line in _lines) {
            line = StringTools.trim(line);
            if (StringTools.startsWith(line, "-js")) {
                var jsOutput = Path.join([path, Path.withoutDirectory(line.split(" ").pop())]);
                _lines[i] = '-js ${jsOutput}';
            } else if  (StringTools.startsWith(line, "-cpp")) {
                _lines[i] = '-cpp ${path}';
            }
            
            i++;
        }
        
        save();
    }
    
    private override function get_main():String {
        var m = null;
        for (line in _lines) {
            line = StringTools.trim(line);
            if (StringTools.startsWith(line, "-main")) {
                m = line.split(" ")[1];
                break;
            }
        }
        return m;
    }
    
    public function load(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        var contents:String = File.getContent(path);
        _lines = contents.split("\n");
        _path = path;
    }
    
    public function save(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        File.saveContent(path, _lines.join("\n"));
        _path = path;
    }
    
    public override function find(path:String):Bool {
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            if (FileSystem.isDirectory(path + "/" + c) == false && StringTools.endsWith(c, ".hxml")) {
                load(path + "/" + c);
                return true;
            }
        }
        return false;
    }
}
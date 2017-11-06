package;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class HxmlFile {
    private var _path = null;
    
    private var _lines:Array<String>;
    
    public function new(path:String) {
        _path = path;
        load();
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
}
package descriptors;
import sys.FileSystem;
import sys.io.File;

class OpenFlApplicationXml extends Descriptor {
    private var _path:String;
    private var _xml:Xml;    
    
    public function new() {
        super();
    }
    
    private override function get_main():String {
        var m = null;
        if (_xml.firstElement().elementsNamed("app").hasNext()) {
            m = _xml.firstElement().elementsNamed("app").next().get("main");
        }
        return m;
    }
    
    public function load(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        var contents:String = File.getContent(path);
        _xml = Xml.parse(contents);
        
        _path = path;
    }
    
    public override function find(path:String):Bool {
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            if (FileSystem.isDirectory(path + "/" + c) == false && (c == "application.xml" || c == "project.xml")) {
                load(path + "/" + c);
                return true;
            }
        }
        return false;
    }
}
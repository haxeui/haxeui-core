package descriptors;
import sys.io.File;

class HxProj extends Descriptor {
    private var _path = null;
    private var _xml:Xml = null;
    
    public function new() {
        super();
    }
    
    private override function get_main():String {
        return null;
    }
    
    public function fixClassPaths(startsWith:String, with:String) {
        var root = _xml.firstElement();
        var classpaths:Xml = root.elementsNamed("classpaths").next();
        for (el in classpaths.elements()) {
            var path = el.get("path");
            if (StringTools.startsWith(path, startsWith)) {
                path = path.substring(startsWith.length, path.length);
                path = with + path;
                el.set("path", path);
            }
        }
        
        save();
    }
    
    public function fixPrefferedSDK(startsWith:String, with:String) {
        var root = _xml.firstElement();
        var output = root.elementsNamed("output").next();
        for (el in output.elements()) {
            if (el.get("preferredSDK") != null && StringTools.startsWith(el.get("preferredSDK"), startsWith)) {
                var preferredSDK = el.get("preferredSDK");
                preferredSDK = preferredSDK.substring(startsWith.length, preferredSDK.length);
                preferredSDK = with + preferredSDK;
                el.set("preferredSDK", preferredSDK);
                break;
            }
        }
        
        save();
    }
    
    public function testMovieCommand(value:String) {
        var root = _xml.firstElement();
        var options:Xml = root.elementsNamed("options").next();
        for (el in options.elements()) {
            if (el.get("testMovieCommand") != null) {
                el.set("testMovieCommand", value);
                break;
            }
        }
        
        save();
    }
    
    public function moviePath(value:String) {
        var root = _xml.firstElement();
        var output:Xml = root.elementsNamed("output").next();
        for (el in output.elements()) {
            if (el.get("path") != null) {
                el.set("path", value);
                break;
            }
        }
        
        save();
    }
    
    public function load(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        var contents:String = File.getContent(path);
        _xml = Xml.parse(contents);
        
        _path = path;
    }
    
    public function save(path:String = null) {
        if (path == null) {
            path = _path;
        }

        File.saveContent(path, _xml.toString());
        
        _path = path;
    }
}
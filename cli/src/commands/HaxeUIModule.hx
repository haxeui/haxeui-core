package commands;

import sys.FileSystem;
import sys.io.File;

class HaxeUIModule {
    private var _path:String = null;
    
    private var _xml:Xml;
    
    public function new(path:String = null) {
        _path = path;
    }
    
    public function addCustomComponent(classPath:String) {
        var root = _xml.firstElement();
        
        var componentsEl = root.elementsNamed("components").next();
        if (componentsEl == null) {
            root.addChild(Xml.parse("<components/>").firstElement());
            componentsEl = root.elementsNamed("components").next();
        }
     
        var found = false;
        for (c in componentsEl.elementsNamed("class")) {
            if (c.get("name") == classPath) {
                found = true;
                break;
            }
        }
        
        if (found == false) {
            componentsEl.addChild(Xml.parse('<class name="${classPath}" />').firstElement());
        }
        
        save();
    }
    
    public function load(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        var xmlString = File.getContent(path);
        _xml = Xml.parse(xmlString);
        
        _path = path;
    }
    
    public function create() {
        _xml = Xml.parse("<module />");
    }
    
    public function save(path:String = null) {
        if (path == null) {
            path = _path;
        }
        
        var sb = new StringBuf();
        Util.prettyPrintXml(_xml.firstElement(), sb);
        var xmlString = sb.toString();
        File.saveContent(path, xmlString);
        
        _path = path;
    }
    
    public static function find(path:String):HaxeUIModule {
        var m = null;
        
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            if (c == "module.xml") {
                m = new HaxeUIModule('${path}/${c}');
                m.load();
                break;
            } else if (FileSystem.isDirectory('${path}/${c}')) {
                m = find('${path}/${c}');
                if (m != null) {
                    break;
                }
            }
        }
        
        return m;
    }
}
package haxe.ui.macros;

#if macro
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;

class Backends2 {
    public static var backends:Map<String, Backend2> = new Map<String, Backend2>();

    macro public static function loadBackends() {
        var paths:Array<String> = Context.getClassPath();
        for (p in paths) {
            findBackendXML(p);
        }
        return macro null;
    }

    private static var _firstBackend:Backend2;
    public static var firstBackend(get, null):Backend2;
    private static function get_firstBackend():Backend2 {
        return _firstBackend;
    }

    private static function findBackendXML(path:String) {
        if (StringTools.trim(path).length == 0) {
            return;
        }
        var paths:Array<String> = FileSystem.readDirectory(path);
        for (p in paths) {
            var file = path + "/" + p;
            if (FileSystem.isDirectory(file) == true) {
                findBackendXML(file);
            } else {
                if (StringTools.endsWith(file, ".config.xml")) {
                    var xmlString = File.getContent(file);
                    var backend:Backend2 = new Backend2();
                    backend.fromXML(Xml.parse(xmlString).firstElement());
                    backends.set(backend.id, backend);
                    if (_firstBackend == null) {
                        _firstBackend = backend;
                    }
                }
            }
        }
    }
}
#end
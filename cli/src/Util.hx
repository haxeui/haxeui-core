package;
import descriptors.DescriptorFactory;
import sys.FileSystem;
import sys.io.File;

class Util {
    public static function log(message:String) {
        Sys.println(" " + message);
    }
    
    public static function mapContains(name:String, params:Array<String>, remove:Bool = false):Bool {
        var b = false;
        
        for (p in params) {
            if (p == name || p == '--${name}') {
                if (remove == true) {
                    params.remove(p);
                }
                b = true;
                break;
            }
        }
        
        return b;
    }
    
    public static function name(params:Params):String {
        var name:String = null;
        for (a in params.additional) {
            if (StringTools.startsWith(a, "--") == false) {
                name = a;
                break;
            }
        }

        var descriptor = DescriptorFactory.find(params.target);
        if (descriptor != null) {
            Util.log('Using name from descriptor "${Type.getClassName(Type.getClass(descriptor))}": "${descriptor.main}"');
            name = descriptor.main;
        }
        
        if (name == null) { // default
            name = "Main";
        }
        
        return name;
    }
    
    public static function backends():Array<String> {
        return ["html5", "hxwidgets", "openfl", "nme", "pixijs", "kha"];
    }
    
    public static function backendString(sep:String = ", "):String {
        return backends().join(sep);
    }
    
    public static function isBackend(s):Bool {
        return (backends().indexOf(s) != -1);
    }
    
    public static function copyDir(src:String, dst:String, recursive = true) {
        FileSystem.createDirectory(dst);
        
        var contents = FileSystem.readDirectory(src);
        for (c in contents) {
            var srcFile = src + "/" + c;
            var dstFile = dst + "/" + c;
            
            if (FileSystem.isDirectory(srcFile) == false) {
                File.copy(srcFile, dstFile);
            } else if (recursive == true) {
                FileSystem.createDirectory(dstFile);
                copyDir(srcFile, dstFile, true);
            }
        }
    }
    
    public static function removeDir(path:String, recursive = true) {
        var contents = FileSystem.readDirectory(path);
        for (c in contents) {
            var file = path + "/" + c;
            if (FileSystem.isDirectory(file) == false) {
                FileSystem.deleteFile(file);
            } else if (recursive == true) {
                removeDir(file);
            }
        }
        
        FileSystem.deleteDirectory(path);
    }
    
    public static function prettyPrintXml(el:Xml, sb:StringBuf, indent:String = "" ) {
        sb.add('${indent}<${el.nodeName}');
        
        var childCount = 0;
        for (c in el.elements()) {
            childCount ++;
        }
        
        for (a in el.attributes()) {
            var v = el.get(a);
            sb.add(' ${a}="${v}"');
        }
        
        if (childCount == 0) {
            sb.add(' />\n');
        } else {
            sb.add('>\n');
        }
        
        for (c in el.elements()) {
            prettyPrintXml(c, sb, indent + "    ");
        }
        
        if (childCount != 0) {
            sb.add('${indent}</${el.nodeName}>\n');
        }
    }
}
package descriptors;

import sys.FileSystem;
import sys.io.File;

class InfoFile extends Descriptor {
    public var properties:Map<String, String> = new Map<String, String>();
    
    private var _dir:String;
    public function new() {
        super();
    }
    
    private override function get_main():String {
        return name;
    }
    
    public var name(get, set):String;
    private function get_name():String {
        return properties.get("name");
    }
    private function set_name(value:String):String {
        properties.set("name", value);
        save(null);
        return value;
    }
    
    public override function find(path:String):Bool {
        if (path == null) {
            path = _dir;
        }
        
        if (FileSystem.exists('${_dir}/.haxeui')) {
            load(path);
        }
        
        return FileSystem.exists('${_dir}/.haxeui');
    }
    
    public function load(dir:String) {
        _dir = dir;
        
        var content = File.getContent('${_dir}/.haxeui');
        for (line in content.split("\n")) {
            line = StringTools.trim(line);
            if (line.length == 0 || StringTools.startsWith(line, "#")) {
                continue;
            }
            var parts = line.split("=");
            properties.set(StringTools.trim(parts[0]), StringTools.trim(parts[1]));
        }
    }
    
    public function save(dir:String) {
        if (dir == null) {
            dir = _dir;
        }
        
        var content = '# generated file simply to hold info about projects created with "haxeui create ..."\n';
        for (k in properties.keys()) {
            content += '${k}=${properties.get(k)}\n';
        }
        File.saveContent('${dir}/.haxeui', content);
        
        _dir = dir;
    }
}
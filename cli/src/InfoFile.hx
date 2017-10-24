package;

import sys.FileSystem;
import sys.io.File;

class InfoFile {
    public var properties:Map<String, String> = new Map<String, String>();
    
    private var _dir:String;
    public function new(dir:String) {
        _dir = dir;
        load();
    }
    
    public var name(get, set):String;
    private function get_name():String {
        return properties.get("name");
    }
    private function set_name(value:String):String {
        properties.set("name", value);
        save();
        return value;
    }
    
    public var exists(get, null):Bool;
    private function get_exists():Bool {
        return FileSystem.exists('${_dir}/.haxeui');
    }
    
    public function load() {
        if (exists == false) {
            return;
        }
        
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
    
    public function save() {
        var content = '# generated file simply to hold info about projects created with "haxeui create ..."\n';
        for (k in properties.keys()) {
            content += '${k}=${properties.get(k)}\n';
        }
        File.saveContent('${_dir}/.haxeui', content);
    }
}
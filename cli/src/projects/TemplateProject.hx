package projects;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;


class TemplateEntry {
    public function new() {
    }
    
    public var src:String;
    public var dst:String;
}


class TemplateProject extends Project {
    public var templates:Array<TemplateEntry> = [];
    
    public function new() {
        super();
    }
    
    public override function execute(params:Map<String, String>) {
        super.execute(params);
        
        var cwd = Sys.getCwd();
        
        for (t in templates) {
            var src = '${cwd}/cli/templates/${name}/${expandString(t.src, params)}';
            var dst = expandString(t.dst, params);
            copyTemplate(src, dst, params);
        }
    }
    
    public static function copyTemplate(src:String, dst:String, vars:Map<String, String> = null) {
        var params:Dynamic = { };
        for (k in vars.keys()) {
            Reflect.setField(params, k, vars.get(k));
        }
        
        src = Path.normalize(src);
        dst = Path.normalize(dst);
        var force = (vars.exists("force") && vars.get("force") == "true");
        
        if (FileSystem.exists(src) == false) {
            throw 'Could not find template file "${src}"';
        }
        
        if (FileSystem.exists(dst) == false || force == true) {
            Util.log('\t- Copying "${src}" to "${dst}"');
            
            var content = File.getContent(src);
            
            var t = new haxe.Template(content);
            content = t.execute(params);
            
            File.saveContent(dst, content);
        } else {
            Util.log('\t- Skipping "${dst}"');
        }
    }
    
}
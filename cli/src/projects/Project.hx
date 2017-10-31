package projects;

import haxe.Resource;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class TemplateEntry {
    public function new() {
    }
    
    public var src:String;
    public var dst:String;
}

class Project {
    public var name:String;
    public var type:String;
    public var subProjects:Array<String> = [];
    public var directories:Array<String> = [];
    
    public var templates:Array<TemplateEntry> = [];
    
    public function new() {
    }
    
    public function execute(params:Map<String, String>) {
        var cwd = Sys.getCwd();
        
        for (subProject in _subProjects) {
            subProject.execute(params);
        }
        
        for (d in directories) {
            d = expandString(d, params);
            mkdirs(d);
        }
        
        for (t in templates) {
            var src = '${cwd}/cli/templates/${name}/${expandString(t.src, params)}';
            var dst = expandString(t.dst, params);
            copyTemplate(src, dst, params);
        }
    }
    
    private var _subProjects:Array<Project> = [];
    private function loadSubProjects() {
        for (s in subProjects) {
            var subProject = Project.load(s);
            _subProjects.push(subProject);
        }
    }
    
    public static function load(name:String):Project {
        var jsonString = Resource.getString('projects/${name}/project.json');
        var parser = new json2object.JsonParser<Project>();
        parser.fromJson(jsonString, 'projects/${name}/project.json');
        var project:Project = parser.value;
        
        if (project != null) {
            project.loadSubProjects();
        }
        
        return project;
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
            log('\t- Copying "${src}" to "${dst}"');
            
            var content = File.getContent(src);
            
            var t = new haxe.Template(content);
            content = t.execute(params);
            
            File.saveContent(dst, content);
        } else {
            log('\t- Skipping "${dst}"');
        }
    }
    
    public static function mkdirs(dir) {
        dir = Path.normalize(dir);
        if (FileSystem.exists(dir) == false) {
            log('\t- Creating directory "${dir}"');
            FileSystem.createDirectory(dir);
        } else {
            log('\t- Skipping "${dir}"');
        }
    }
    
    private static function expandString(s:String, vars:Map<String, String> = null):String {
        if (vars == null) {
            return s;
        }
        
        for (k in vars.keys()) {
            s = StringTools.replace(s, "${" + k + "}", vars.get(k));
        }
        
        return s;
    }
    
    public static function log(message:String) {
        Sys.println(message);
    }
}

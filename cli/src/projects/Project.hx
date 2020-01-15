package projects;

import haxe.io.Path;
import sys.FileSystem;

class Project {
    public var name:String;
    public var type:String;
    public var subProjects:Array<String> = [];
    public var directories:Array<String> = [];
    public var post:Array<String> = [];
    
    
    public function new() {
    }
    
    public function execute(params:Map<String, String>) {
        for (subProject in _subProjects) {
            subProject.execute(params);
        }
        
        for (d in directories) {
            d = expandString(d, params);
            mkdirs(d);
        }
    }

    public function executePost(params:Params) {
        for (subProject in _subProjects) {
            subProject.executePost(params);
        }
        
        for (pc in post) {
            var p:Post = Type.createInstance(Type.resolveClass(pc), []);
            p.execute(params);
        }
    }
    
    private var _subProjects:Array<Project> = [];
    private function loadSubProjects() {
        for (s in subProjects) {
            var subProject = Project.load(s);
            _subProjects.push(subProject);
        }
    }
    
    public function mkdirs(dir) {
        dir = Path.normalize(dir);
        if (FileSystem.exists(dir) == false) {
            Util.log('\t- Creating directory "${dir}"');
            FileSystem.createDirectory(dir);
        } else {
            Util.log('\t- Skipping "${dir}"');
        }
    }
    
    private function expandString(s:String, vars:Map<String, String> = null):String {
        if (vars == null) {
            return s;
        }
        
        for (k in vars.keys()) {
            s = StringTools.replace(s, "${" + k + "}", vars.get(k));
        }
        
        var env = Sys.environment();
        for (k in env.keys()) {
            s = StringTools.replace(s, "${" + k + "}", env.get(k));
        }
        
        return s;
    }
    
    public static function load(name:String):Project {
        var project:Project = ProjectFactory.get(name);
        project._subProjects = [];
        if (project.subProjects == null) {
            project.subProjects = [];
        }
        if (project.directories == null) {
            project.directories = [];
        }
        if (project.post == null) {
            project.post = [];
        }
        
        if (project != null) {
            project.loadSubProjects();
        }
        
        return project;
    }
    
}

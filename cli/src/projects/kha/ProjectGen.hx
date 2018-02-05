package projects.kha;

import descriptors.HxmlFile;
import projects.Post;
import sys.io.File;

class ProjectGen extends Post {
    private var _cleanUp:Bool = true;
    public function new(cleanUp:Bool = true) {
        super();
        _cleanUp = cleanUp;
    }
    
    public override function execute(params:Params) {
        Sys.setCwd(params.target);
        
        var target = "html5";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        }
        
        var p = new ProcessHelper();
        
        if (target == "html5") {
            Util.copyDir("assets", "temp/kha/assets");
        
            p.run("node", ["Kha/make", "html5", "--to", "temp/kha"]);
            
            File.copy("temp/kha/project-html5.hxml", "kha-html5.hxml");
            Util.copyDir("temp/kha/html5", "build/kha/html5");
            Util.copyDir("temp/kha/html5-resources", "build/kha/html5-resources");
            
            var hxml = new HxmlFile();
            hxml.load("kha-html5.hxml");
            hxml.changeOutput("build/kha/html5");
        } else if (target == "windows") {
            Util.copyDir("assets", "build/kha/assets");
            
            p.run("node", ["Kha/make", "windows", "--to", "build/kha", "--visualstudio", "vs2015"]);
            
            File.copy("build/kha/project-windows.hxml", "kha-windows.hxml");
            
            var hxml = new HxmlFile();
            hxml.load("kha-windows.hxml");
            hxml.changeOutput("build/kha/windows-build/Sources");
        }
        
        Sys.setCwd(params.cwd);
        
        if (_cleanUp == true) {
            cleanUp(params);
        }
    }
    
    private function cleanUp(params:Params) {
        Sys.setCwd(params.target);
        
        var target = "html5";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        }
        
        if (target == "html5") {
            Util.removeDir("temp");
        } else if (target == "windows") {
            
        }
        
        Sys.setCwd(params.cwd);
    }
}
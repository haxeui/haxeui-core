package projects.kha;

import descriptors.DescriptorFactory;
import descriptors.HxProj;
import sys.io.File;

class ProjectGenFD extends ProjectGen {
    public function new() {
        super(false);
    }
    
    public override function execute(params:Params) {
        super.execute(params);
        
        Sys.setCwd(params.target);
        
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ");
        
        var target = "html5";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        }
        
        if (target == "html5") {
            var name = Util.name(params);
            File.copy('temp/kha/${name}-html5.hxproj', "kha-html5.hxproj");
            
            var hxproj:HxProj = new HxProj();
            hxproj.load("kha-html5.hxproj");
            hxproj.fixClassPaths("..\\..\\", "");
            hxproj.fixPrefferedSDK("..\\..\\", "");
            hxproj.testMovieCommand("build\\kha\\html5\\index.html");
            hxproj.moviePath("build\\kha\\html5\\kha.js");
        } else if (target == "windows") {
            
        }
        
        cleanUp(params);
        
        Sys.setCwd(params.cwd);
    }
}
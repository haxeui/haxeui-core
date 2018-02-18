package runs;
import projects.ProjectFactory;

class RunFactory {
    public static function get(id:String, params:Params):Run {
        var r:Run = null;
        
        var target = "html5";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        }
        
        switch (id) {
            case "html5":
                r = new WebServerRun("build/html5");
            case "openfl":
                r = new ProcessRun(["openfl", "run", target]);
            case "kha":
                if (target == "html5") {
                    r = new WebServerRun("build/kha/html5");
                }
            case "pixijs":
                r = new WebServerRun("build/pixijs");
            case "hxwidgets":
                var main = Util.name(params);
                trace(main);
                r = new ProcessRun(['build/hxwidgets/${main}']);
            case "nme":
                r = new ProcessRun(["nme", "run"]);
        }
        
        return r;
    }
}
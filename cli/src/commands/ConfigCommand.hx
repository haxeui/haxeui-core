package commands;
import projects.Project;

class ConfigCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        if (params.backend == null) {
            Util.log("ERROR: no backend specified");
            return;
        }
        
        var force = Util.mapContains("force", params.additional, true);
        var flashDevelop = Util.mapContains("flash-develop", params.additional, true);
        
        //////////////////////////////////////////////////////
        // handle name
        //////////////////////////////////////////////////////
        var name:String = params.additional.shift();
        var info:InfoFile = new InfoFile(params.target);
        if (name == null) {
            name = info.name;
        }
        if (name == null) { // default
            name = "Main";
        }
        info.name = name;
        //////////////////////////////////////////////////////
        // handle pacakge / main
        //////////////////////////////////////////////////////
        var pkg = name.split(".");
        var main = "Main";
        if (pkg.length > 0) {
            main = pkg.pop();
        }
        //////////////////////////////////////////////////////
        
        var fullMain = pkg.concat([main]).join(".");
        Util.log('Creating haxeui-${params.backend} files for "${fullMain}"');
        
        if (flashDevelop == true) {
            params.backend += "-flash-develop";
        }

        var templateParams:Map<String, String> = [
            "target" => params.target,
            "packagePath" => pkg.join("/"),
            "package" => pkg.join("."),
            "main" => main,
            "name" => main,
            "output" => main,
            "fullMain" => fullMain
        ];
        
        if (force == true) {
            templateParams.set("force", "true");
        }
        
        var project = Project.load(params.backend);
        project.execute(templateParams);
    }
}
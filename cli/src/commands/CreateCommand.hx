package commands;
import descriptors.DescriptorFactory;
import descriptors.InfoFile;
import projects.Project;

class CreateCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        if (params.backend == null) {
            Util.log("ERROR: no backend specified");
            return;
        }
        
        if (Util.isBackend(params.backend) == false) {
            Util.log('ERROR: backend "${params.backend}" not recognized');
            return;
        }
        
        var force = Util.mapContains("force", params.additional, true);
        var flashDevelop = Util.mapContains("flash-develop", params.additional, true);

        //////////////////////////////////////////////////////
        // handle name
        //////////////////////////////////////////////////////
        var name:String = Util.name(params);
        
        var info:InfoFile = new InfoFile();
        info.save(params.target);
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
        project.executePost(params);
    }
    
    public override function displayHelp() {
        Util.log('Creates project files for given backend\n');
        Util.log('Usage : haxeui create <${Util.backendString(" | ")}> [options]\n');
        Util.log('Shared Options : ');
        Util.log('  --flash-develop : generate flash develop project files');
        Util.log('  --force : force overwriting of existing files');
        Util.log('');
        Util.log('Kha Options : ');
        Util.log('  --html : generate html5 project (default)');
        Util.log('  --windows : generate windows project');
    }
}
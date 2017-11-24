package commands;

import projects.ProjectFactory;

class CustomComponentCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        trace(params.additional);
        
        var force = Util.mapContains("force", params.additional, true);
        
        var classPath = params.additional.pop();
        if (classPath == null) {
            Util.log("ERROR: no class name specified");
            return;
        }
        
        var xmlFile = params.additional.pop();
        
        var pkg = classPath.split(".");
        var className = pkg.pop();
        if (xmlFile == null) {
            xmlFile = 'assets/custom/${className.toLowerCase()}.xml';
        }
        
        
        var templateParams:Map<String, String> = [
            "target" => params.target,
            "packagePath" => pkg.join("/"),
            "package" => pkg.join("."),
            "className" => className,
            "xmlFile" => xmlFile
        ];
        
        if (force == true) {
            templateParams.set("force", "true");
        }
        
        var project = ProjectFactory.get("custom-component");
        project.execute(templateParams);
        project.executePost(params);
        
        var module = HaxeUIModule.find('${params.target}/src');
        if (module == null) {
            module = new HaxeUIModule('${params.target}/src/module.xml');
            module.create();
            module.save();
        }
        
        module.addCustomComponent(classPath);
    }
    
    public override function displayHelp() {
        Util.log('Creates files for a custom component\n');
        Util.log('Usage : haxeui custom-component <class> [options]\n');
        Util.log('Shared Options : ');
        Util.log('  --force : force overwriting of existing files');
    }
}

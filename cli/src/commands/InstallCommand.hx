package commands;
import installs.InstallFactory;

class InstallCommand extends Command {
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
        
        var i = InstallFactory.get(params.backend);
        if (i == null) {
            throw 'Install not found for "${params.backend}"';
        }
        
        i.execute(params);
    }
    
    public override function displayHelp() {
        Util.log('Installs given backend and any dependancies\n');
        Util.log('Usage : haxeui install <${Util.backendString(" | ")}>\n');
    }
}
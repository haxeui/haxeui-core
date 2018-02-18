package commands;

import updates.UpdateFactory;

class UpdateCommand extends Command {
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
        
        var u = UpdateFactory.get(params.backend);
        if (u == null) {
            throw 'Update not found for "${params.backend}"';
        }
        
        u.execute(params);
    }
    
    public override function displayHelp() {
        Util.log('Updates given backend and any dependancies\n');
        Util.log('Usage : haxeui update <${Util.backendString(" | ")}>\n');
    }
}
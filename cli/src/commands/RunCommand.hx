package commands;

import runs.RunFactory;

class RunCommand extends Command  {
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
        
        var r = RunFactory.get(params.backend, params);
        if (r == null) {
            throw 'Run not found for "${params.backend}"';
        }
        
        r.execute(params);
    }
    
    public override function displayHelp() {
        Util.log('Runs given app built with specified backend\n');
        Util.log('Usage : haxeui run <${Util.backendString(" | ")}>\n');
    }
}
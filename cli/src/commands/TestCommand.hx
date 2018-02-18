package commands;

import test.TestFactory;

class TestCommand extends Command {
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
        
        var t = TestFactory.get(params.backend, params);
        if (t == null) {
            throw 'Test not found for "${params.backend}"';
        }
        
        t.execute(params);
    }
    
    public override function displayHelp() {
        Util.log('Tests given app built with specified backend\n');
        Util.log('Usage : haxeui run <${Util.backendString(" | ")}>\n');
    }
}
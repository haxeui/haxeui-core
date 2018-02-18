package commands;

import builds.BuildFactory;

class BuildCommand extends Command {
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
        
        
        var build = BuildFactory.get(params.backend);
        if (build == null) {
            Util.log("ERROR: no build found");
        }
        
        build.execute(params);
    }
    
    public override function displayHelp() {
        Util.log('Builds project for given backend\n');
        Util.log('Usage : haxeui build <${Util.backendString(" | ")}> [options]\n');
        Util.log('OpenFL Options : ');
        Util.log('  --html : build html5 project (default)');
        Util.log('  --windows : build windows project');
        Util.log('  --neko : build neko project');
        Util.log('  --flash : build flash project');
        Util.log('  --android : build android project');
        Util.log('');
        Util.log('NME Options : ');
        Util.log('  --windows : build windows project (default)');
        Util.log('  --neko : build neko project');
        Util.log('  --flash : build flash project');
        Util.log('  --android : build android project');
        Util.log('');
        Util.log('Kha Options : ');
        Util.log('  --html : build html5 project (default)');
        Util.log('  --windows : build windows project');
    }
}
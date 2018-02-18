package runs;
import sys.io.Process;

class ProcessRun extends Run {
    private var _args:Array<String> = [];
    public function new(args:Array<String>) {
        super();
        _args = args;
    }
    
    public override function execute(params:Params) {
        Util.log('running: ${_args.join(" ")}');
        
        Sys.setCwd(params.target);
        var c = _args.shift();
        Sys.command(c, _args);
        Sys.setCwd(params.cwd);
    }
}
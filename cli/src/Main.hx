package;

import commands.CommandFactory;
import projects.Project;
import sys.FileSystem;
import sys.io.File;

class Main {
	public static function main() {
        Util.log("");
        
        var args = Sys.args();
        
        var cwd = Sys.getCwd();
        var target = args.pop();
        var command = args.shift();
        
        var backend = null;
        for (a in args) {
            if (Util.isBackend(a)) {
                backend = a;
                args.remove(a);
                break;
            }
        }
        
        var params:Params = {
            cwd: cwd,
            target: target,
            command: command,
            backend: backend,
            additional: args
        }
        
        if (params.command == null) {
            Util.log('ERROR: no command specified');
            return;
        }
        
        var command = CommandFactory.get(params.command);
        if (command == null) {
            Util.log('ERROR: command "${params.command}" not recognized');
            return;
        }
        
        command.execute(params);
    }
}

package builds;
import haxe.io.Eof;
import haxe.io.Input;
import neko.vm.Thread;
import sys.FileSystem;
import sys.io.Process;

class ProcessBuild extends Build {
    private var _command:String;
    private var _requiredFiles:Array<String>;
    
    public function new(command:String, requiredFiles:Array<String> = null) {
        super();
        _command = command;
        _requiredFiles = requiredFiles;
    }
    
    public override function execute(params:Params) {
        Sys.setCwd(params.target);
        
        if (_requiredFiles != null) {
            for (f in _requiredFiles) {
                if (FileSystem.exists(f) == false) {
                    Util.log('ERROR: required file "${f}" not found, running "haxeui config ${params.backend}" may fix this');
                    Sys.setCwd(params.cwd);
                    return;
                }
            }
        }
        
        var args = args(params);
        Util.log('Building for haxeui-${params.backend} using "${_command} ${args.join(" ")}"\n');
        var p = new Process(_command, args);
        
        var outThread = Thread.create(printStreamThread);
        outThread.sendMessage(p.stdout);
        
        var errThread = Thread.create(printStreamThread);
        errThread.sendMessage(p.stderr);
        
        p.exitCode(true);
        p.close();
        
        Sys.setCwd(params.cwd);
    }
    
    private function args(params:Params):Array<String> {
        return [];
    }
    
    private function printStreamThread() {
        var stream:Input = Thread.readMessage(true);
        while (true) {
            try {
                var line = stream.readLine();
                Util.log(line);
            } catch (e:Eof) {
                break;
            } catch (e:Dynamic) {
                trace(e);
                break;
            }
        }
    }
}
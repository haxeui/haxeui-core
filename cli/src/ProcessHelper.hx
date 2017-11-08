package;

import haxe.io.Eof;
import haxe.io.Input;
import neko.vm.Thread;
import sys.io.Process;

class ProcessHelper {
    public function new() {
    }
    
    public function run(command:String, args:Array<String> = null) {
        if (args == null) {
            args = [];
        }
        
        var p = new Process(command, args);
        
        Util.log('running: ${command} ${args.join(" ")}');
        
        var outThread = Thread.create(printStreamThread);
        outThread.sendMessage(p.stdout);
        
        var errThread = Thread.create(printStreamThread);
        errThread.sendMessage(p.stderr);
        
        p.exitCode(true);
        p.close();
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
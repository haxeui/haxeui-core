package commands;

import sys.FileSystem;
import sys.io.File;

class SetupCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        var haxePath = Sys.getEnv("HAXEPATH");
        if (haxePath != null) {
            // almost certainly a much better way to be doing this!
            var haxeLibPath = Sys.getCwd(); //HaxeLibHelper.getLibPath("haxeui-core");
            
            Util.log('Setting up haxeui tools from "${haxeLibPath}"');
            File.copy('${haxeLibPath}/cli/Alias.hx', 'Alias.hx');
            File.copy('${haxeLibPath}/cli/alias.hxml', 'alias.hxml');
            
            Util.log("Building haxeui alias");
            Sys.command("haxe", ['alias.hxml']);
            
            Util.log('Copying alias to "${haxePath}"');
            if (FileSystem.exists('haxeui.exe')) {
                File.copy('haxeui.exe', '${haxePath}/haxeui.exe');
            }
            if (FileSystem.exists('haxeui')) {
                File.copy('haxeui', '${haxePath}/haxeui');
            }
            
            Util.log('Cleaning up');
            FileSystem.deleteFile("Alias.hx");
            FileSystem.deleteFile("alias.hxml");
            FileSystem.deleteFile("haxeui.n");
            if (FileSystem.exists('haxeui.exe')) {
                FileSystem.deleteFile("haxeui.exe");
            }
            if (FileSystem.exists('haxeui')) {
                FileSystem.deleteFile("haxeui");
            }
        } else { // more hacky!
            Util.log("Setting up alias (may need sudo)");
            var content = "#!/bin/sh\nhaxelib run haxeui-core \"$@\"";
            File.saveContent("/usr/local/bin/haxeui", content);
        }
    }
}
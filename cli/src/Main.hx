package;

import projects.Project;
import sys.FileSystem;
import sys.io.File;

class Main {
	public static function main() {
        var args = Sys.args();
        
        var cwd = Sys.getCwd();
        var target = args.pop();
        
        var command = null;
        var backend = null;
        var force = false;
        var flashDevelop = false;
        var name = null;
        for (a in args) {
            if (isCommand(a)) {
                command = a;
            } else if (isBackend(a)) {
                backend = a;
            } else if (a == "--force") {
                force = true;
            } else if (a == "--flash-develop") {
                flashDevelop = true;
            } else {
                name = a;
            }
        }
        
        if (command == null) {
            log("ERROR: no command specified");
            return;
        }
        
        if (command == "setup") {
            // almost certainly a much better way to be doing this!
            var haxeLibPath = Sys.getCwd(); //HaxeLibHelper.getLibPath("haxeui-core");
            
            log('Setting up haxeui tools from "${haxeLibPath}"');
            File.copy('${haxeLibPath}/cli/Alias.hx', 'Alias.hx');
            File.copy('${haxeLibPath}/cli/alias.hxml', 'alias.hxml');
            
            log("Building haxeui alias");
            Sys.command("haxe", ['alias.hxml']);
            
            var haxePath = Sys.getEnv("HAXEPATH");
            log('Copying alias to "${haxePath}"');
            if (FileSystem.exists('haxeui.exe')) {
                File.copy('haxeui.exe', '${haxePath}/haxeui.exe');
            }
            if (FileSystem.exists('haxeui')) {
                File.copy('haxeui', '${haxePath}/haxeui');
            }
            
            log('Cleaning up');
            FileSystem.deleteFile("Alias.hx");
            FileSystem.deleteFile("alias.hxml");
            FileSystem.deleteFile("haxeui.n");
            if (FileSystem.exists('haxeui.exe')) {
                FileSystem.deleteFile("haxeui.exe");
            }
            if (FileSystem.exists('haxeui')) {
                FileSystem.deleteFile("haxeui");
            }
            return;
        }
        
        
        if (backend == null) {
            log("ERROR: no backend specified");
            return;
        }
        
        //////////////////////////////////////////////////////
        // handle name
        //////////////////////////////////////////////////////
        var info:InfoFile = new InfoFile(target);
        if (name == null) {
            name = info.name;
        }
        if (name == null) { // default
            name = "Main";
        }
        info.name = name;
        //////////////////////////////////////////////////////
        // handle pacakge / main
        //////////////////////////////////////////////////////
        var pkg = name.split(".");
        var main = "Main";
        if (pkg.length > 0) {
            main = pkg.pop();
        }
        //////////////////////////////////////////////////////
        
        var fullMain = pkg.concat([main]).join(".");
        log('Creating haxeui-${backend} files for "${fullMain}"');
        
        if (flashDevelop == true) {
            backend += "-flash-develop";
        }

        var params:Map<String, String> = [
            "target" => target,
            "packagePath" => pkg.join("/"),
            "package" => pkg.join("."),
            "main" => main,
            "name" => main,
            "output" => main,
            "fullMain" => fullMain
        ];
        
        if (force == true) {
            params.set("force", "true");
        }
        
        var project = Project.load(backend);
        project.execute(params);
	}
    
    private static function isSwitch(s):Bool {
        return s == "--force";
    }
    
    private static function isCommand(s):Bool {
        return s == "config" || s == "setup";
    }
    
    private static function isBackend(s):Bool {
        return s == "html5"
               || s == "hxwidgets"
               || s == "openfl"
               || s == "nme"
               ;
    }
    
    public static function log(message:String) {
        Sys.println(message);
    }
}

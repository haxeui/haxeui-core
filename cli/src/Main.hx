package;

import projects.Project;

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
        return s == "create";
    }
    
    private static function isBackend(s):Bool {
        return s == "html5"
               || s == "hxwidgets"
               || s == "openfl"
               ;
    }
    
    public static function log(message:String) {
        Sys.println(message);
    }
}

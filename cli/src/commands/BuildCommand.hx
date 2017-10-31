package commands;
import builds.BuildFactory;
import sys.FileSystem;
import sys.io.Process;

class BuildCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        if (params.backend == null) {
            Util.log("ERROR: no backend specified");
            return;
        }
        
        
        var build = BuildFactory.get(params.backend);
        if (build == null) {
            Util.log("ERROR: no build found");
        }
        
        build.execute(params);
        
        return;
        
        Sys.setCwd(params.target);
        
        Util.log('Building for haxeui-${params.backend}');
        
        if (FileSystem.exists('${params.backend}.hxml') == false) {
            Util.log('ERROR: "${params.backend}.hxml" not found, run "config ${params.backend}" to create one');
            return;
        }
        
        var p = new Process("haxe", ['${params.backend}.hxml']);
        var err = StringTools.trim(p.stderr.readAll().toString());
        if (err.length > 0) {
            Util.log("err: " + err);
        }
        var out = StringTools.trim(p.stdout.readAll().toString());
        if (out.length > 0) {
            Util.log("out: " + out);
        }
        p.close();
        
        //trace(output);
        
        //for (line in output.split("\n")) {
         //   log(line);
            /*
            line = StringTools.trim(line);
            if (line.length == 0 || StringTools.startsWith(line, lib) == false) {
                continue;
            }
            
            var versions = line.split(" ");
            versions.shift();
            for (v in versions) {
                if (StringTools.startsWith(v, "[") && StringTools.endsWith(v, "]")) {
                    path = v.substr(1, v.length - 2);
                    if (StringTools.startsWith(path, "dev:")) {
                        path = path.substr(4, path.length);
                    }
                    
                    break;
                }
            }
            */
       // }
        
        
        //Sys.command("haxe", ['html5.hxml']);
        Sys.setCwd(params.cwd);
    }
}
package installs.kha;
import installs.HaxeLibInstall;

class KhaInstall extends HaxeLibInstall {
    public function new() {
        super([
            "haxeui-core",
            "haxeui-kha",
            "hscript"
        ]);
    }
    
    public override function execute(params:Params) {
        super.execute(params);
        
        Sys.setCwd(params.target);
        
        var p = new ProcessHelper();
        p.run("git", ["init"]);
        p.run("git", ["submodule", "add", "https://github.com/KTXSoftware/Kha"]);
        p.run("git", ["submodule", "update", "--init", "--recursive"]);
        
        Sys.setCwd(params.cwd);
    }
}
package updates.kha;

class KhaUpdate extends HaxeLibUpdate {
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
        p.run("git", ["submodule", "update", "--init", "--recursive"]);
        
        Sys.setCwd(params.cwd);
    }
}
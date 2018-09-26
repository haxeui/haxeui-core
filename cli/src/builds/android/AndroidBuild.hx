package builds.android;

class AndroidBuild extends ProcessBuild {
    public function new() {
        super("haxe", ["android.hxml"]);
    }

    private override function args(params:Params):Array<String> {
        return ["android.hxml"];
    }
    
    public override function execute(params:Params) {
        super.execute(params);
        
        Sys.setCwd(params.target + "/build/android");
        trace(Sys.getCwd());
        
        var process:ProcessHelper = new ProcessHelper();
        process.run('gradlew.bat', ["build", "-x", "lint"]);
        
        Sys.setCwd(params.cwd);
    }
}

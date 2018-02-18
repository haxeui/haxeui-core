package builds.nme;
import builds.ProcessBuild;

class NmeBuild extends ProcessBuild {
    public function new() {
        super("haxelib", ["project.nmml"]);
    }
    
    private override function args(params:Params):Array<String> {
        var target = "flash";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        } else if (Util.mapContains("neko", params.additional)) {
            target = "neko";
        } else if (Util.mapContains("flash", params.additional)) {
            target = "flash";
        } else if (Util.mapContains("android", params.additional)) {
            target = "android";
        }
        return ["run", "nme", "build", "project.nmml", target];
    }
}
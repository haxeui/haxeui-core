package builds.openfl;

import builds.ProcessBuild;

class OpenFLBuild extends ProcessBuild {
    public function new() {
        super("openfl", ["application.xml"]);
    }
    
    private override function args(params:Params):Array<String> {
        var target = "html5";
        if (Util.mapContains("windows", params.additional)) {
            target = "windows";
        } else if (Util.mapContains("neko", params.additional)) {
            target = "neko";
        } else if (Util.mapContains("flash", params.additional)) {
            target = "flash";
        } else if (Util.mapContains("android", params.additional)) {
            target = "android";
        }
        return ["build", "application.xml", target];
    }
}
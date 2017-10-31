package builds.pixijs;

import builds.ProcessBuild;

class PixiJsBuilder extends ProcessBuild {
    public function new() {
        super("haxe", ["pixijs.hxml"]);
    }
    
    private override function args(params:Params):Array<String> {
        return ["pixijs.hxml"];
    }
}
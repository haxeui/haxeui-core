package builds.winforms;

import builds.ProcessBuild;

class WinFormsBuild extends ProcessBuild {
    public function new() {
        super("haxe", ["winforms.hxml"]);
    }
    
    private override function args(params:Params):Array<String> {
        return ["winforms.hxml"];
    }
}
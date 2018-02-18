package builds.html5;

import builds.ProcessBuild;

class Html5Build extends ProcessBuild {
    public function new() {
        super("haxe", ["html5.hxml"]);
    }
    
    private override function args(params:Params):Array<String> {
        return ["html5.hxml"];
    }
}

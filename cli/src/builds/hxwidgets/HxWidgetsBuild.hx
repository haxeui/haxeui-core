package builds.hxwidgets;

class HxWidgetsBuild extends ProcessBuild {
    public function new() {
        super("haxe", ["hxwidgets.hxml"]);
    }
    
    private override function args(params:Params):Array<String> {
        return ["hxwidgets.hxml"];
    }
}
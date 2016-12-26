package haxe.ui.parsers.ui.resolvers;

class AssetResourceResolver extends ResourceResolver {
    private var _rootFile:String;
    private var _rootDir:String;

    public function new(rootFile:String, params:Map<String, Dynamic> = null) {
        super(params);
        _rootFile = rootFile;
        var arr:Array<String> = _rootFile.split("/");
        arr.pop();
        _rootDir = arr.join("/");
        if (arr.length > 1) {
            _rootDir += "/";
        }
    }
    
    public override function getResourceData(r:String):String {
        var f:String = _rootDir + r;
        return ToolkitAssets.instance.getText(f);
    }
}

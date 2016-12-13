package haxe.ui.parsers.ui.resolvers;

class ResourceResolver {
    private var _params:Map<String, Dynamic>;

    public function new(params:Map<String, Dynamic> = null) {
        _params = params;
    }

    public function getResourceData(r:String):String {
        return null;
    }

    public function extension(path:String):String {
        if (path.indexOf(".") == -1) {
            return null;
        }
        var arr:Array<String> = path.split(".");
        var extension:String = arr[arr.length - 1];
        return extension;
    }
}
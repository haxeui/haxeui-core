package haxe.ui.parsers.ui.resolvers;

class ResourceResolver {
	public function new() {
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
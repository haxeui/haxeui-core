package descriptors;

class DescriptorFactory {
    public static function get(type:String):Descriptor {
        var d:Descriptor = null;
        switch (type) {
            case "hxml":
                d = new HxmlFile();
            case "openfl":
                d = new OpenFlApplicationXml();
            case "nme":
                d = new NMEProjectNmml();
            case "kha":
                d = new KhaFile();
            case "haxeui":
                d = new InfoFile();
            case "hxproj":
                d = new HxProj();
        }
        return d;
    }
    
    public static function find(path:String, order:Array<String> = null):Descriptor {
        var d = null;
        
        if (order == null) {
            order = ["openfl", "nme", "kha", "hxproj", "hxml", "haxeui"];
        }
        
        for (o in order) {
            var temp = get(o);
            if (o != null && temp.find(path) == true) {
                d = temp;
                break;
            }
        }
        
        return d;
    }
}
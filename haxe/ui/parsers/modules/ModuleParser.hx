package haxe.ui.parsers.modules;

class ModuleParser {
    private static var _parsers:Map<String, Class<ModuleParser>>;

    public function new() {
    }

    public function parse(data:String, defines:Map<String, String>):Module {
        throw "Module parser not implemented!";
    }

    public static function get(extension:String):ModuleParser {
        defaultParsers();

        var cls:Class<ModuleParser> = _parsers.get(extension);
        if (cls == null) {
            return null;
        }

        var instance:ModuleParser = Type.createInstance(cls, []);
        if (instance == null) {
            throw 'Could not create module parser instance "${cls}"';
        }

        return instance;
    }

    private static function defaultParsers() {
        if (_parsers == null) {
            register("xml", XMLParser);
        }
    }

    public static function register(extension:String, cls:Class<ModuleParser>) {
        if (_parsers == null) {
            _parsers = new Map<String, Class<ModuleParser>>();
        }
        _parsers.set(extension, cls);
    }
}
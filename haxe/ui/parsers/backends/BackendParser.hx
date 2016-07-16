package haxe.ui.parsers.backends;

class BackendParser {
    private static var _parsers:Map<String, Class<BackendParser>>;

    public function new() {
    }

    public function parse(data:String):Backend {
        throw "Backend parser not implemented!";
    }

    public static function get(extension:String):BackendParser {
        defaultParsers();

        var cls:Class<BackendParser> = _parsers.get(extension);
        if (cls == null) {
            throw 'No backend parser found for "${extension}"';
        }

        var instance:BackendParser = Type.createInstance(cls, []);
        if (instance == null) {
            throw 'Could not create backend parser instance "${cls}"';
        }

        return instance;
    }

    private static function defaultParsers() {
        if (_parsers == null) {
            register("xml", XMLParser);
            register("json", JSONParser);
            #if yaml
            register("yaml", YAMLParser);
            register("yml", YAMLParser);
            #end
        }
    }

    public static function register(extension:String, cls:Class<BackendParser>) {
        if (_parsers == null) {
            _parsers = new Map<String, Class<BackendParser>>();
        }
        _parsers.set(extension, cls);
    }
}
package haxe.ui.parsers.locale;

class LocaleParser {
    private static var _parsers:Map<String, Class<LocaleParser>>;

    public function new() {
    }

    public function parse(data:String):Map<String, String> {
        throw "Locale parser not implemented!";
    }

    public static function get(extension:String):LocaleParser {
        defaultParsers();

        var cls:Class<LocaleParser> = _parsers.get(extension);
        if (cls == null) {
            throw 'No locale parser found for "${extension}"';
        }

        var instance:LocaleParser = Type.createInstance(cls, []);
        if (instance == null) {
            throw 'Could not create locale parser instance "${cls}"';
        }

        return instance;
    }

    private static function defaultParsers() {
        register("properties", PropertiesParser);
    }

    public static function register(extension:String, cls:Class<LocaleParser>) {
        if (_parsers == null) {
            _parsers = new Map<String, Class<LocaleParser>>();
        }
        _parsers.set(extension, cls);
    }
} 

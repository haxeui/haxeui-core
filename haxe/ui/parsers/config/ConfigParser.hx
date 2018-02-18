package haxe.ui.parsers.config;

import haxe.ui.util.GenericConfig;

class ConfigParser {
    private static var _parsers:Map<String, Class<ConfigParser>>;

    public function new() {

    }

    public function parse(data:String, defines:Map<String, String>):GenericConfig {
        throw "Config parser not implemented!";
    }

    public static function get(extension:String):ConfigParser {
        defaultParsers();

        var cls:Class<ConfigParser> = _parsers.get(extension);
        if (cls == null) {
            return null;
        }

        var instance:ConfigParser = Type.createInstance(cls, []);
        if (instance == null) {
            throw 'Could not create config parser instance "${cls}"';
        }

        return instance;
    }

    private static function defaultParsers() {
        if (_parsers == null) {
            register("xml", XMLParser);
        }
    }

    public static function register(extension:String, cls:Class<ConfigParser>) {
        if (_parsers == null) {
            _parsers = new Map<String, Class<ConfigParser>>();
        }
        _parsers.set(extension, cls);
    }
}
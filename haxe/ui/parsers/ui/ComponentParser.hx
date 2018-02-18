package haxe.ui.parsers.ui;

import haxe.ui.parsers.ui.resolvers.ResourceResolver;

class ComponentParser {
    private static var _parsers:Map<String, Class<ComponentParser>>;

    private var _resourceResolver:ResourceResolver;

    public function new() {
    }

    public function parse(data:String, resourceResolver:ResourceResolver = null):ComponentInfo {
        throw "Component parser not implemented!";
    }

    public static function get(extension:String):ComponentParser {
        defaultParsers();

        var cls:Class<ComponentParser> = _parsers.get(extension);
        if (cls == null) {
            throw 'No component parser found for "${extension}"';
        }

        var instance:ComponentParser = Type.createInstance(cls, []);
        if (instance == null) {
            throw 'Could not create component parser instance "${cls}"';
        }

        return instance;
    }

    private static function defaultParsers() {
        if (_parsers == null) {
            register("xml", XMLParser);
        }
    }

    public static function register(extension:String, cls:Class<ComponentParser>) {
        if (_parsers == null) {
            _parsers = new Map<String, Class<ComponentParser>>();
        }
        _parsers.set(extension, cls);
    }

    private static var _nextId:Int = 0;
    private static function nextId(prefix:String = "component"):String {
        var s = prefix + _nextId;
        _nextId++;
        return s;
    }

    private static function float(value:String):Float {
        return Std.parseFloat(value);
    }

    private static function isPercentage(value:String):Bool {
        if (value.indexOf("%") == value.length - 1) {
            return true;
        }
        return false;
    }
}
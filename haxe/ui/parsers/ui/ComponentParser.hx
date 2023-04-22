package haxe.ui.parsers.ui;

import haxe.ui.parsers.ui.resolvers.ResourceResolver;

#if (haxe_ver >= 4.1)

class ComponentParserException extends haxe.Exception {
    public var fileName:String;
    public var original:haxe.Exception;
    public function new(message:String, fileName:String, original:haxe.Exception, ?previous:haxe.Exception, ?native:Any):Void {
        super(message, previous, native);
        this.fileName = fileName;
        this.original = original;
    }
}

#end

class ComponentParser {
    private static var _parsers:Map<String, Class<ComponentParser>>;

    private var _resourceResolver:ResourceResolver;

    public function new() {
    }

    public function parse(data:String, resourceResolver:ResourceResolver = null, fileName:String = null):ComponentInfo {
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
        var f = Std.parseFloat(value);
        if (Math.isNaN(f)) {
            return 0;
        }
        return f;
    }

    private static function isPercentage(value:String):Bool {
        if (value.indexOf("%") == value.length - 1) {
            return true;
        }
        return false;
    }
}

package haxe.ui.util;

#if (macro || sys)
import sys.io.File;
#end

class Properties {
    private var _props:Map<String, String>;
    public function new() {
        _props = new Map<String, String>();
    }

    #if (macro || sys)
    public function fromFile(filePath:String) {
        _props = new Map<String, String>();
        var content:String = File.getContent(filePath);
        var lines:Array<String> = content.split("\n");
        for (line in lines) {
            line = StringTools.trim(line);
            if (line.length != 0) {
                var parts:Array<String> = line.split("=");
                _props.set(parts[0], parts[1]);
            }
        }
    }
    #end

    public function getProp(name:String, defaultValue = null):String {
        var v:String = defaultValue;
        if (_props.exists(name)) {
            v = _props.get(name);
        }
        return v;
    }

    public function getPropInt(name:String, defaultValue:Int = 0):Int {
        var v:Int = defaultValue;
        var stringValue = getProp(name);
        if (stringValue != null) {
            v = Std.parseInt(stringValue);
        }
        return v;
    }

    public function getPropBool(name:String, defaultValue:Bool = false):Bool {
        var v:Bool = defaultValue;
        var stringValue = getProp(name);
        if (stringValue != null) {
            v = stringValue == "true";
        }
        return v;
    }

    public function getPropCol(name:String, defaultValue:Int = 0x000000):Int {
        var v:Int = defaultValue;
        var stringValue = getProp(name);
        if (stringValue != null) {
            v = ColorUtil.parseColor(stringValue);
        }
        return v;
    }

    public function setProp(name:String, value:String) {
        _props.set(name, value);
    }

    public function names():Iterator<String> {
        return _props.keys();
    }

    public function addAll(p:Properties) {
        for (name in p.names()) {
            _props.set(name, p.getProp(name));
        }
    }
}
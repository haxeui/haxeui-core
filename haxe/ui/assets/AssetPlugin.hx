package haxe.ui.assets;

class AssetPlugin {
    private var _props:Map<String, String>;

    public function new() {

    }

    public function invoke(asset:Dynamic):Dynamic {
        return asset;
    }

    public function setProperty(name:String, value:String) {
        if (_props == null) {
            _props = new Map<String, String>();
        }
        _props.set(name, value);
    }

    public function getProperty(name:String, defaultValue:String = null):String {
        if (_props == null) {
            return defaultValue;
        }
        var v:String = _props.get(name);
        if (v == null) {
            v = defaultValue;
        }
        return v;
    }
}
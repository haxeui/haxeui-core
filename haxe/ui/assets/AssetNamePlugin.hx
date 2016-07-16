package haxe.ui.assets;

class AssetNamePlugin extends AssetPlugin {
    public var startsWith:String;
    public var prefix:String;
    public var replaceWith:String;
    public var removeExtension:Bool;
    public var findChars:String;

    public function new() {
        super();
    }

    public override function setProperty(name:String, value:String) {
        switch (name) {
            case "startsWith":
                startsWith = value;
            case "prefix":
                prefix = value;
            case "replaceWith":
                replaceWith = value;
            case "removeExtension":
                removeExtension = (value == "true");
            case "findChars":
                findChars = value;
            default:
                super.setProperty(name, value);
        }
    }

    public override function invoke(asset:Dynamic):Dynamic {
        if (Std.is(asset, String)) {
            var stringAsset:String = asset;
            var match:Bool = true;
            if (startsWith != null) {
                match = StringTools.startsWith(stringAsset, startsWith);
            }

            if (match == true) {
                if (prefix != null) {
                    asset = prefix + stringAsset;
                }
                if (replaceWith != null) {
                    asset = StringTools.replace(stringAsset, startsWith, replaceWith);
                    if (findChars != null) {
                        for (n in 0...findChars.length) {
                            asset = StringTools.replace(asset, findChars.charAt(n), replaceWith);
                        }
                    }
                }

                stringAsset = asset;
                if (removeExtension == true) {
                    var n = stringAsset.lastIndexOf(".");
                    if (n != -1) {
                        asset = stringAsset.substr(0, n);
                    }
                }
            }
        }
        return asset;
    }
}
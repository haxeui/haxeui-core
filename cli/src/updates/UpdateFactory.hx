package updates;

import updates.HaxeLibUpdate;
import updates.kha.KhaUpdate;

class UpdateFactory {
    public static function get(id:String):Update {
        var u:Update = null;
        
        switch (id) {
            case "openfl":
                u = new HaxeLibUpdate(["haxeui-openfl", "openfl", "lime"]);
            case "nme":
                u = new HaxeLibUpdate(["haxeui-openfl", "nme"]);
            case "html5":
                u = new HaxeLibUpdate(["haxeui-html5"]);
            case "hxwidgets":
                u = new HaxeLibUpdate(["haxeui-hxwidgets", "hxWidgets", "hxcpp"]);
            case "pixijs":
                u = new HaxeLibUpdate(["haxeui-pixijs", "pixijs"]);
            case "kha": {
                u = new KhaUpdate();
            }
        }
        
        return u;
    }
}
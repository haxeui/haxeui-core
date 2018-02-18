package installs;

import installs.kha.KhaInstall;

class InstallFactory {
    public static function get(id:String):Install {
        var i:Install = null;
        
        switch (id) {
            case "openfl":
                i = new HaxeLibInstall(["haxeui-openfl", "openfl", "lime"]);
            case "nme":
                i = new HaxeLibInstall(["haxeui-openfl", "nme"]);
            case "html5":
                i = new HaxeLibInstall(["haxeui-html5"]);
            case "hxwidgets":
                i = new HaxeLibInstall(["haxeui-hxwidgets", "hxWidgets", "hxcpp"]);
            case "pixijs":
                i = new HaxeLibInstall(["haxeui-pixijs"]);
            case "kha": {
                i = new KhaInstall();
            }
        }
        
        return i;
    }
}
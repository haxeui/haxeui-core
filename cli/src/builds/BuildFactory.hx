package builds;

import builds.html5.Html5Build;
import builds.hxwidgets.HxWidgetsBuild;
import builds.kha.KhaBuild;
import builds.nme.NmeBuild;
import builds.openfl.OpenFLBuild;
import builds.pixijs.PixiJsBuild;

class BuildFactory {
    public static function get(backend:String):Build {
        var b:Build = null;
        
        switch (backend) {
            case "html5":
                b = new Html5Build();
            case "openfl":
                b = new OpenFLBuild();
            case "nme":
                b = new NmeBuild();
            case "hxwidgets":
                b = new HxWidgetsBuild();
            case "pixijs":
                b = new PixiJsBuild();
            case "kha":
                b = new KhaBuild();
            case _:    
        }
        
        return b;
    }
}
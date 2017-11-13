package installs;

import installs.kha.KhaInstall;

class InstallFactory {
    public static function get(id:String):Install {
        var i:Install = null;
        
        switch (id) {
            case "kha": {
                i = new KhaInstall();
            }
        }
        
        return i;
    }
}
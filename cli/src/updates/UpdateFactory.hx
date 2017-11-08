package updates;

import updates.kha.KhaUpdate;

class UpdateFactory {
    public static function get(id:String):Update {
        var u:Update = null;
        
        switch (id) {
            case "kha": {
                u = new KhaUpdate();
            }
        }
        
        return u;
    }
}
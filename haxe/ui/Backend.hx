package haxe.ui;

import haxe.ui.backend.BackendBase;

class Backend extends BackendBase {
    public static var id(get, null):String;
    private static function get_id():String {
        return BackendBase.id;
    }
}
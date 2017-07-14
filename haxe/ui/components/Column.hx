package haxe.ui.components;

class Column extends Button {
    public function new() {
        super();
    }

    public var sortable(get, set):Bool;
    private function get_sortable():Bool {
        return hasClass("sortable");
    }
    private function set_sortable(value:Bool):Bool {
        if (value == true) {
            addClass("sortable");
        } else {
            removeClass("sortable");
        }
        return value;
    }
}
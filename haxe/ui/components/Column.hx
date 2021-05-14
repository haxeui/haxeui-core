package haxe.ui.components;

import haxe.ui.components.Button.ButtonEvents;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.MouseEvent;

@:composite(Events)
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

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ButtonEvents  {
    private var _column:Column;
    
    public function new(column:Column) {
        super(column);
        _column = column;
    }
    
    private override function onMouseDown(event:MouseEvent) {
        var components = _column.findComponentsUnderPoint(event.screenX, event.screenY, InteractiveComponent);
        components.remove(_column);
        if (components.length == 0) {
            super.onMouseDown(event);
        }
    }
}
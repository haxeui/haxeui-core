package haxe.ui.containers;

import haxe.ui.layouts.HorizontalContinuousLayout;
import haxe.ui.layouts.HorizontalLayout;

/**
 A `Box` component that lays its children out horizontally
**/
@:dox(icon = "/icons/ui-split-panel.png")
class HBox extends Box {
    public function new() {
        super();
        layout = new HorizontalLayout();
    }

    @:clonable public var continuous(get, set):Bool;
    private function get_continuous():Bool {
        return Std.is(_layout, HorizontalContinuousLayout);
    }
    private function set_continuous(value:Bool):Bool {
        if (value == true) {
            layout = new HorizontalContinuousLayout();
        } else {
            layout = new HorizontalLayout();
        }
        return value;
    }
}
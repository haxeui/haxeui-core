package haxe.ui.containers;

import haxe.ui.core.IClonable;
import haxe.ui.layouts.AbsoluteLayout;

/**
 `Layout` that does not modify a components `top` or `left` positions
**/
@:dox(icon = "/icons/ui-layered-pane.png")
class Absolute extends Box implements IClonable<Absolute> {
    public function new() {
        super();
        layout = new AbsoluteLayout();
    }
}
package haxe.ui.containers;

import haxe.ui.layouts.AbsoluteLayout;

/**
 `Layout` that does not modify a components `top` or `left` positions
**/
@:dox(icon = "/icons/ui-layered-pane.png")
class Absolute extends Box {
    public function new() {
        super();
        layout = new AbsoluteLayout();
    }
}
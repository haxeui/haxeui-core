package haxe.ui.containers;

import haxe.ui.layouts.VerticalLayout;

/**
 A `Box` component that lays its children out vertically
**/
@:dox(icon = "/icons/ui-split-panel-vertical.png")
class VBox extends Box {
    public function new() {
        super();
        layout = new VerticalLayout();
    }
}
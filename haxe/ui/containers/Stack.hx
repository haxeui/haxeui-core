package haxe.ui.containers;

import haxe.ui.core.IClonable;

/**
 A `Box` component where only one child is visible at a time
**/
@:dox(icon = "/icons/ui-layered-pane.png")
class Stack extends Box implements IClonable<Stack> {
    public function new() {
        super();
    }
}
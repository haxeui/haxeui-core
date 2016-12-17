package haxe.ui.containers;

import haxe.ui.core.IClonable;
import haxe.ui.layouts.HorizontalContinuousLayout;

/**
 A `Box` component that lays its children out horizontally
**/
@:dox(icon = "/icons/ui-split-panel.png")
class ContinuousHBox extends Box implements IClonable<ContinuousHBox> {
    public function new() {
        super();
        layout = new HorizontalContinuousLayout();
    }
}
